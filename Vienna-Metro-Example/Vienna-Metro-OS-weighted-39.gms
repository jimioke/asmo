$TITLE "M E T R O  M A P  A U T O M A T I O N"
$ontext
March 21 2013
SMALL WORKING MODEL
MIP Metro Map Automation
number of vertices n = 4
number of edges m = 3
number of multiedges m' =  0
number of faces f = 1
$offtext
$inlinecom [ ]
$eolcom //

* replace g(u,u) with h(u,u) when dealing epscm!!!

*=========================================================================
*                                  DATA
*=========================================================================
SETS
u           "vertices"           /1*84/
b(u)        "subset of vertices with more than one spanning edge"
f           "faces"              /1*8/
ml          "metro lines"        / 1  "Brown"
                                   2  "g"
                                   3  "DarkOrange"
                                   4  "DarkViolet"
                                   5  "r"
                                   /
r           "relative position"  / prec, orig, succ /
c           "compass directions" / N, S, E, W, NE, NW, SE, SW /
e(u,u)      "edges as directed and undirected pairs"
n(u,u,u,u,f)  "nonincident edges"
S           "cost factors"       /1*2/
j(u,u)      "set of degrees"
k           "objective functions"   / bend, rposition / ;


Alias (u, v, w, ww);
Alias (ml, nl);

Scalars
        M     "maximum length or width of map" / 248 /
        minedg   "minimum edge length"            / 2 /
        maxedg  "maximum edge length"            / 4 /
        maxpen  "maximum pendant edge length"            / 2 /
        minint  "minimum internal edge length"            / 2 /
        dmin  "minimum edge distance"          / 1 /
        ;

Parameter    weight(S) weights / 1  .0001
                                 2  .9999  /
    ;

* Degree of vertices
Parameter deg(u)  degree /
$ondelim
$include deg.csv
$offdelim
/ ;
b(u)=yes$(deg(u) ge 2);

* Directed edges
Set   e1(u,v) directed edges  /
$ondelim
$include dpath1.csv
$offdelim
/ ;

* Reverse-directed edges
Set   e2(u,v) reverse-directed edges  /
$ondelim
$include dpath2.csv
$offdelim
/ ;

* All edges
Set e(u,v);
e(u,v) = e1(u,v) + e2(u,v);

* Edge-face incidence
Table   ef(u,v,f) edge-face incidence
$ondelim
$include faces.csv
$offdelim
 ;

* Edge adjacency
Parameter  e2e(u,v,w,ww) edge adjacency /
$ondelim
$include e2e.csv
$offdelim
/ ;

* Sectoral positioning
Table  sec(u,v,r) sectors
$ondelim
$include sec.csv
$offdelim
;
sec(u,v,r)$e2(u,v) = mod((sec(v,u,r)+4),8);

* Metro lines
Table   lin(u,v,ml)  metro lines
$ondelim
$include lin.csv
$offdelim
;

* Vertex-line incidence
Table   lin2(u,ml) vertex-line incidence
$ondelim
$include lin2.csv
$offdelim
;

* Non-incident edges
n(u,v,w,ww,f)$((ord(u) ne ord(w)) and (ord(u) ne ord(ww)) and (ord(v) ne ord(w)) and (ord(v) ne ord(ww)))
                 = yes$(ef(u,v,f)*ef(w,ww,f)) - yes$e2e(u,v,w,ww)  ;

* Vertices with spanning edges (degree 2 or greater)
j(u,v) = e(u,v)$b(u);

* Original sector positions of spanning edges
parameter j2(u,v);
j2(u,v)$j(u,v) = sec(u,v,'orig');

Parameter  linp(u,v) line params /
$ondelim
$include linp.csv
$offdelim
/ ;

* Set of pendant edges (strictly belonging to external face)
parameter pe(u,v);
pe(u,v) = yes$ef(u,v,'1') and not (ef(u,v,'2')+ef(u,v,'3')+ef(u,v,'4')+ef(u,v,'5')+ef(u,v,'6')+ef(u,v,'7')+ef(u,v,'8'));

* Nonadjacent edge pairings on external face
set pep(u,v,w,ww);
pep(u,v,w,ww)$(  linp(u,v) ne linp(w,ww) and ord(u) lt ord(w) and ord(v) ne ord(ww) and not e2e(u,v,w,ww)  ) =
          yes$(pe(u,v)*pe(w,ww)  ) ;
* - yes$e2e(u,v,w,ww) ;

* Set minimum length for all edges, and then for interior face (4,5,6,7,8) edges
parameter lmin(u,v);
lmin(u,v)$e1(u,v) = minedg;
lmin(u,v)$(ef(u,v,'4') or ef(u,v,'5') or ef(u,v,'6') or ef(u,v,'7') or ef(u,v,'8')) = minint;

* Sets max length for all edges, and then for pendant edges
parameter lmax(u,v);
lmax(u,v)$e1(u,v) = maxedg;
lmax(u,v)$pe(u,v) = maxpen;


*=========================================================================
*                                VARIABLES
*=========================================================================
VARIABLES
  Z
  z2(u)     -45 degree coordinate
  deltadir(ml,u,v,w)  sector difference btw adjacent egdes uv and uw as measure of angle btw;

*INTEGER VARIABLES
*;


POSITIVE VARIABLES
  cs2, cs1
  x(u)      x coordinate
  y(u)      y coordinate
  z1(u)     +45 degree coordinate
  dir(u,v)         octilinear direction of edge uv
  bd(ml,u,v,w)     bend cost of angle between uv and vw
  ;


BINARY VARIABLES
  alpha(u,v,r)   closest octilinear approximation
  beta(u,v)
  delta1(ml,u,v,w)
  delta2(ml,u,v,w)
  rpos(u,v)        relative position penalty
  gamma(u,v,w,ww,c) binary variable selecting compass orientation
  ;




*=========================================================================
*                               EQUATIONS
*=========================================================================
EQUATIONS
  xlim(u)
  ylim(u)
  defz1(u)
  defz2(u)
  octicon1(u,v)
  octicon2a(u,v), octicon2b(u,v)
  octicon3a(r,u,v),octicon3b(r,u,v),octicon3c(r,u,v)
  octicon3d(r,u,v),octicon3e(r,u,v),octicon3f(r,u,v)
  octicon3g(r,u,v),octicon3h(r,u,v),octicon3i(r,u,v)
  octicon3j(r,u,v),octicon3k(r,u,v),octicon3l(r,u,v)
  octicon3m(r,u,v),octicon3n(r,u,v),octicon3o(r,u,v)
  octicon3p(r,u,v),octicon3q(r,u,v),octicon3r(r,u,v)
  octicon3s(r,u,v),octicon3t(r,u,v),octicon3u(r,u,v)
  octicon3v(r,u,v),octicon3w(r,u,v),octicon3x(r,u,v)
  cvocon1(u)
  cvocon9a, cvocon9b, cvocon9c, cvocon9d
  cvocon11a, cvocon11b, cvocon11c, cvocon11d
  cvocon19a, cvocon19b, cvocon19c, cvocon19d
  cvocon35a, cvocon35b, cvocon35c, cvocon35d, cvocon35e
  cvocon37a, cvocon37b, cvocon37c, cvocon37d
  cvocon39a, cvocon39b, cvocon39c, cvocon39d
  cvocon38a, cvocon38b, cvocon38c, cvocon38d
  cvocon50a, cvocon50b, cvocon50c, cvocon50d
  cvocon52a, cvocon52b, cvocon52c, cvocon52d
  cvocon66a, cvocon66b, cvocon66c, cvocon66d
  edgecon(u,v,w,ww)
  edgeconE1(u,v,w,ww),  edgeconE2(u,v,w,ww),  edgeconE3(u,v,w,ww),  edgeconE4(u,v,w,ww)
  edgeconNE1(u,v,w,ww), edgeconNE2(u,v,w,ww), edgeconNE3(u,v,w,ww), edgeconNE4(u,v,w,ww)
  edgeconN1(u,v,w,ww),  edgeconN2(u,v,w,ww),  edgeconN3(u,v,w,ww),  edgeconN4(u,v,w,ww)
  edgeconNW1(u,v,w,ww), edgeconNW2(u,v,w,ww), edgeconNW3(u,v,w,ww), edgeconNW4(u,v,w,ww)
  edgeconW1(u,v,w,ww),  edgeconW2(u,v,w,ww),  edgeconW3(u,v,w,ww),  edgeconW4(u,v,w,ww)
  edgeconSW1(u,v,w,ww), edgeconSW2(u,v,w,ww), edgeconSW3(u,v,w,ww), edgeconSW4(u,v,w,ww)
  edgeconS1(u,v,w,ww),  edgeconS2(u,v,w,ww),  edgeconS3(u,v,w,ww),  edgeconS4(u,v,w,ww)
  edgeconSE1(u,v,w,ww), edgeconSE2(u,v,w,ww), edgeconSE3(u,v,w,ww), edgeconSE4(u,v,w,ww)
  telcon1(u,v)
  telcon2(u,v)
  telcon3(u,v)
  telcon4(u,v)
  rposcon1(u,v)
  rposcon2(u,v)
  ddi(ml,u,v,w)
  bendcon1(ml,u,v,w)
  bendcon2(ml,u,v,w)
  objbend
  objrpos
  obj
;

* Map limits
xlim(u).. x(u) =l= M;
ylim(u).. y(u) =l= M;

* Z coordinates
defz1(u).. z1(u) =e= (x(u) + y(u))/2;
defz2(u).. z2(u) =e= (x(u) - y(u))/2;

* Octilinearity constraints  (H1, H3)
octicon1(u,v)$e1(u,v)..     sum(r, alpha(u,v,r)) =e= 1;
octicon2a(u,v)$e1(u,v)..    dir(u,v) =e= sum(r,(sec(u,v,r)*alpha(u,v,r))) ;
octicon2b(u,v)$e2(u,v)..    dir(u,v) =e= sum(r,(sec(u,v,r)*alpha(v,u,r))) ;//replace g w/ h

octicon3a(r,u,v)$(sec(u,v,r)=0 and e1(u,v))..   y(u) - y(v) =l=  M*(1-alpha(u,v,r));
octicon3b(r,u,v)$(sec(u,v,r)=0 and e1(u,v))..  -y(u) + y(v) =l=  M*(1-alpha(u,v,r));
octicon3c(r,u,v)$(sec(u,v,r)=0 and e1(u,v))..  -x(u) + x(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3d(r,u,v)$(sec(u,v,r)=1 and e1(u,v))..   z2(u) - z2(v) =l=  M*(1-alpha(u,v,r));
octicon3e(r,u,v)$(sec(u,v,r)=1 and e1(u,v))..  -z2(u) + z2(v) =l=  M*(1-alpha(u,v,r));
octicon3f(r,u,v)$(sec(u,v,r)=1 and e1(u,v))..  -z1(u) + z1(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3g(r,u,v)$(sec(u,v,r)=2 and e1(u,v))..   x(u) - x(v) =l=  M*(1-alpha(u,v,r));
octicon3h(r,u,v)$(sec(u,v,r)=2 and e1(u,v))..  -x(u) + x(v) =l=  M*(1-alpha(u,v,r));
octicon3i(r,u,v)$(sec(u,v,r)=2 and e1(u,v))..  -y(u) + y(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3j(r,u,v)$(sec(u,v,r)=3 and e1(u,v))..   z1(u) - z1(v) =l=  M*(1-alpha(u,v,r));
octicon3k(r,u,v)$(sec(u,v,r)=3 and e1(u,v))..  -z1(u) + z1(v) =l=  M*(1-alpha(u,v,r));
octicon3l(r,u,v)$(sec(u,v,r)=3 and e1(u,v))..   z2(u) - z2(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3m(r,u,v)$(sec(u,v,r)=4 and e1(u,v))..   y(u) - y(v) =l=  M*(1-alpha(u,v,r));
octicon3n(r,u,v)$(sec(u,v,r)=4 and e1(u,v))..  -y(u) + y(v) =l=  M*(1-alpha(u,v,r));
octicon3o(r,u,v)$(sec(u,v,r)=4 and e1(u,v))..   x(u) - x(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3p(r,u,v)$(sec(u,v,r)=5 and e1(u,v))..   z2(u) - z2(v) =l=  M*(1-alpha(u,v,r));
octicon3q(r,u,v)$(sec(u,v,r)=5 and e1(u,v))..  -z2(u) + z2(v) =l=  M*(1-alpha(u,v,r));
octicon3r(r,u,v)$(sec(u,v,r)=5 and e1(u,v))..   z1(u) - z1(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3s(r,u,v)$(sec(u,v,r)=6 and e1(u,v))..   x(u) - x(v) =l=  M*(1-alpha(u,v,r));
octicon3t(r,u,v)$(sec(u,v,r)=6 and e1(u,v))..  -x(u) + x(v) =l=  M*(1-alpha(u,v,r));
octicon3u(r,u,v)$(sec(u,v,r)=6 and e1(u,v))..   y(u) - y(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);

octicon3v(r,u,v)$(sec(u,v,r)=7 and e1(u,v))..   z1(u) - z1(v) =l=  M*(1-alpha(u,v,r));
octicon3w(r,u,v)$(sec(u,v,r)=7 and e1(u,v))..  -z1(u) + z1(v) =l=  M*(1-alpha(u,v,r));
octicon3x(r,u,v)$(sec(u,v,r)=7 and e1(u,v))..  -z2(u) + z2(v) =g= -M*(1-alpha(u,v,r)) + lmin(u,v);


* Circular vertex orders (H2)
cvocon1(u)$b(u).. sum(v, beta(u,v)$j(u,v)) =e= 1;

cvocon9a.. dir('9','32') =l= dir('9','10')  - 1 + 8*beta('9','32');
cvocon9b.. dir('9','10') =l= dir('9','31')  - 1 + 8*beta('9','10');
cvocon9c.. dir('9','31') =l= dir('9','8')  - 1 + 8*beta('9','31');
cvocon9d.. dir('9','8') =l= dir('9','32')  - 1 + 8*beta('9','8');

cvocon11a.. dir('11','48') =l= dir('11','12')  - 1 + 8*beta('11','48');
cvocon11b.. dir('11','12') =l= dir('11','47')  - 1 + 8*beta('11','12');
cvocon11c.. dir('11','47') =l= dir('11','10')  - 1 + 8*beta('11','47');
cvocon11d.. dir('11','10') =l= dir('11','48')  - 1 + 8*beta('11','10');

cvocon19a.. dir('19','20') =l= dir('19','42')  - 1 + 8*beta('19','20');
cvocon19b.. dir('19','42') =l= dir('19','18')  - 1 + 8*beta('19','42');
cvocon19c.. dir('19','18') =l= dir('19','41')  - 1 + 8*beta('19','18');
cvocon19d.. dir('19','41') =l= dir('19','20')  - 1 + 8*beta('19','41');

cvocon35a.. dir('35','36') =l= dir('35','52')  - 1 + 8*beta('35','36');
cvocon35b.. dir('35','52') =l= dir('35','62')  - 1 + 8*beta('35','52');
cvocon35c.. dir('35','62') =l= dir('35','34')  - 1 + 8*beta('35','62');
cvocon35d.. dir('35','34') =l= dir('35','73')  - 1 + 8*beta('35','34');
cvocon35e.. dir('35','73') =l= dir('35','36')  - 1 + 8*beta('35','73');

cvocon37a.. dir('37','38') =l= dir('37','53')  - 1 + 8*beta('37','38');
cvocon37b.. dir('37','53') =l= dir('37','36')  - 1 + 8*beta('37','53');
cvocon37c.. dir('37','36') =l= dir('37','54')  - 1 + 8*beta('37','36');
cvocon37d.. dir('37','54') =l= dir('37','38')  - 1 + 8*beta('37','54');

cvocon38a.. dir('38','74') =l= dir('38','39')  - 1 + 8*beta('38','74');
cvocon38b.. dir('38','39') =l= dir('38','52')  - 1 + 8*beta('38','39');
cvocon38c.. dir('38','52') =l= dir('38','37')  - 1 + 8*beta('38','52');
cvocon38d.. dir('38','37') =l= dir('38','74')  - 1 + 8*beta('38','37');

cvocon39a.. dir('39','65') =l= dir('39','40')  - 1 + 8*beta('39','65');
cvocon39b.. dir('39','40') =l= dir('39','64')  - 1 + 8*beta('39','40');
cvocon39c.. dir('39','64') =l= dir('39','38')  - 1 + 8*beta('39','64');
cvocon39d.. dir('39','38') =l= dir('39','65')  - 1 + 8*beta('39','38');

cvocon50a.. dir('50','51') =l= dir('50','63')  - 1 + 8*beta('50','51');
cvocon50b.. dir('50','63') =l= dir('50','49')  - 1 + 8*beta('50','63');
cvocon50c.. dir('50','49') =l= dir('50','62')  - 1 + 8*beta('50','49');
cvocon50d.. dir('50','62') =l= dir('50','51')  - 1 + 8*beta('50','62');

cvocon52a.. dir('52','53') =l= dir('52','38')  - 1 + 8*beta('52','53');
cvocon52b.. dir('52','38') =l= dir('52','51')  - 1 + 8*beta('52','38');
cvocon52c.. dir('52','51') =l= dir('52','35')  - 1 + 8*beta('52','51');
cvocon52d.. dir('52','35') =l= dir('52','53')  - 1 + 8*beta('52','35');

cvocon66a.. dir('66','67') =l= dir('66','75')  - 1 + 8*beta('66','67');
cvocon66b.. dir('66','75') =l= dir('66','65')  - 1 + 8*beta('66','75');
cvocon66c.. dir('66','65') =l= dir('66','74')  - 1 + 8*beta('66','65');
cvocon66d.. dir('66','74') =l= dir('66','67')  - 1 + 8*beta('66','74');
;



* Edge spacing constraints (H4)
edgecon(u,v,w,ww)$pep(u,v,w,ww).. sum(c, gamma(u,v,w,ww,c)) =g= 1;

edgeconE1(u,v,w,ww)$pep(u,v,w,ww).. x(w) - x(u)  =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE2(u,v,w,ww)$pep(u,v,w,ww).. x(w) - x(v)  =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE3(u,v,w,ww)$pep(u,v,w,ww).. x(ww) - x(u) =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE4(u,v,w,ww)$pep(u,v,w,ww).. x(ww) - x(v) =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;

edgeconNE1(u,v,w,ww)$pep(u,v,w,ww).. z1(w) - z1(u)  =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE2(u,v,w,ww)$pep(u,v,w,ww).. z1(w) - z1(v)  =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE3(u,v,w,ww)$pep(u,v,w,ww).. z1(ww) - z1(u) =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE4(u,v,w,ww)$pep(u,v,w,ww).. z1(ww) - z1(v) =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;

edgeconN1(u,v,w,ww)$pep(u,v,w,ww).. y(w) - y(u)  =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN2(u,v,w,ww)$pep(u,v,w,ww).. y(w) - y(v)  =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN3(u,v,w,ww)$pep(u,v,w,ww).. y(ww) - y(u) =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN4(u,v,w,ww)$pep(u,v,w,ww).. y(ww) - y(v) =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;

edgeconNW1(u,v,w,ww)$pep(u,v,w,ww).. -z2(w) + z2(u)  =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW2(u,v,w,ww)$pep(u,v,w,ww).. -z2(w) + z2(v)  =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW3(u,v,w,ww)$pep(u,v,w,ww).. -z2(ww) + z2(u) =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW4(u,v,w,ww)$pep(u,v,w,ww).. -z2(ww) + z2(v) =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;

edgeconW1(u,v,w,ww)$pep(u,v,w,ww).. -x(w) + x(u)  =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW2(u,v,w,ww)$pep(u,v,w,ww).. -x(w) + x(v)  =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW3(u,v,w,ww)$pep(u,v,w,ww).. -x(ww) + x(u) =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW4(u,v,w,ww)$pep(u,v,w,ww).. -x(ww) + x(v) =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;

edgeconSW1(u,v,w,ww)$pep(u,v,w,ww).. -z1(w) + z1(u)  =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW2(u,v,w,ww)$pep(u,v,w,ww).. -z1(w) + z1(v)  =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW3(u,v,w,ww)$pep(u,v,w,ww).. -z1(ww) + z1(u) =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW4(u,v,w,ww)$pep(u,v,w,ww).. -z1(ww) + z1(v) =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;

edgeconS1(u,v,w,ww)$pep(u,v,w,ww).. -y(w) + y(u)  =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS2(u,v,w,ww)$pep(u,v,w,ww).. -y(w) + y(v)  =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS3(u,v,w,ww)$pep(u,v,w,ww).. -y(ww) + y(u) =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS4(u,v,w,ww)$pep(u,v,w,ww).. -y(ww) + y(v) =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;

edgeconSE1(u,v,w,ww)$pep(u,v,w,ww).. z2(w) - z2(u)  =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE2(u,v,w,ww)$pep(u,v,w,ww).. z2(w) - z2(v)  =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE3(u,v,w,ww)$pep(u,v,w,ww).. z2(ww) - z2(u) =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE4(u,v,w,ww)$pep(u,v,w,ww).. z2(ww) - z2(v) =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;

* Line Bends (S1 - soft constraint 1)
ddi(ml,u,v,w)$(lin(u,v,ml) and lin(u,v,ml)).. deltadir(ml,u,v,w) =e= dir(u,v) - dir(v,w);

*$(f(u,v) and f(v,w))

* Bend constraints
bendcon1(ml,u,v,w)$(lin(u,v,ml) and lin(v,w,ml))..  bd(ml,u,v,w) =g= deltadir(ml,u,v,w) - 8*delta1(ml,u,v,w) + 8*delta2(ml,u,v,w); 
bendcon2(ml,u,v,w)$(lin(u,v,ml) and lin(v,w,ml)).. -bd(ml,u,v,w) =l= deltadir(ml,u,v,w) - 8*delta1(ml,u,v,w) + 8*delta2(ml,u,v,w);

* Relative position constraint S2
rposcon1(e1)..   M*rpos(e1) =g= dir(e1) - sec(e1,'orig');
rposcon2(e1)..  -M*rpos(e1) =l= dir(e1) - sec(e1,'orig');

* Total edge length S3 constraints
telcon1(u,v)$e1(u,v)..  x(u) - x(v) =l= lmax(u,v);
telcon2(u,v)$e1(u,v).. -x(u) + x(v) =l= lmax(u,v);
telcon3(u,v)$e1(u,v)..  y(u) - y(v) =l= lmax(u,v);
telcon4(u,v)$e1(u,v).. -y(u) + y(v) =l= lmax(u,v);



*OBJECTIVE
objbend.. cs1 =e= sum(ml, sum( (u,v,w)$(lin(u,v,ml) and lin(v,w,ml)), bd(ml,u,v,w) )  );
objrpos.. cs2 =e= sum(e1, rpos(e1));
obj.. Z =e= weight('1')*cs1 + weight('2')*cs2 ;


*=========================================================================
*                               MODEL
*=========================================================================
MODEL automap /   all  /;


set combinations singobjmodels /R0*R38/ ;

Table newweights(combinations, S)  updater for weight
$ondelim
$include weight_combinations.csv
$offdelim
;

parameter    resultantcs1(combinations)  collector for level of cs1;
parameter    resultantcs2(combinations)  collector for level of cs2;


Set modelattrib model solution information to collect
     / modelstat, solvestat, objval /;
Parameter
      gussoptions / UpdateType 1, Optfile 1 /
      solutionstatus(combinations,modelattrib) Solution status report with initial vaues
              / #combinations.(ModelStat na, SolveStat na, ObjVal na) /;

display solutionstatus;
set dict   / combinations  .scenario  .''
             gussoptions   .opt       .solutionstatus
             weight        .param     .newweights
             cs1           .level     .resultantcs1
	     cs2           .level     .resultantcs2
           /
;

automap.optcr = 0;
automap.threads=4;
automap.reslim=5000;

Solve automap using mip minimizing Z scenario dict;

option resultantcs1:0:0:1;
option resultantcs2:0:0:1;

display resultantcs1, resultantcs2, solutionstatus;

set Error(combinations) No solution found;
Error(combinations) = resultantcs1(combinations) = 0;
abort$(card(error)) 'Missing solution for some scenarios', error;



$ontext
SOLVE automap minimizing Z using MIP;
file coords /coordinates.csv/ ; put  coords ;
coords.lj=1; [label justification, left]
put 'x1'',', 'x2'',','y1'',', 'y2'',','ln'',','co'/;
loop((u,v,ml), put$(lin(u,v,ml)) x.l(u)',', x.l(v)',',y.l(u)',',y.l(v)',', ord(ml)',', ml.te(ml)/);
putclose coords ;

display cs1.l, cs2.l, Z.l, dir.l;
$offtext

