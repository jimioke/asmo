$TITLE "M E T R O  M A P  A U T O M A T I O N"
$ontext
Jimi Oke
March 21 2013
WORKING MODEL - Solves Vienna Network
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

Parameter    weight(S) weights / 1  .5
                                 2  .5 /
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
parameter pe(u,v);
pe(u,v) = yes$ef(u,v,'1') and not (ef(u,v,'2')+ef(u,v,'3')+ef(u,v,'4')+ef(u,v,'5')+ef(u,v,'6')+ef(u,v,'7')+ef(u,v,'8'));

set pep(u,v,w,ww);
pep(u,v,w,ww)$(  linp(u,v) ne linp(w,ww) and ord(u) lt ord(w) and ord(v) ne ord(ww) and not e2e(u,v,w,ww)  ) =
          yes$(pe(u,v)*pe(w,ww)  ) ;
* - yes$e2e(u,v,w,ww) ;

parameter lmin(u,v);
lmin(u,v)$e1(u,v) = minedg;
lmin(u,v)$(ef(u,v,'4') or ef(u,v,'5') or ef(u,v,'6') or ef(u,v,'7') or ef(u,v,'8')) = minint;

parameter lmax(u,v);
lmax(u,v)$e1(u,v) = maxedg;
lmax(u,v)$pe(u,v) = maxpen;


*=========================================================================
*                                VARIABLES
*=========================================================================
VARIABLES
*  Z
*  cs1
*  cs2
  z(k)                objective func variables
    z2(u)     -45 degree coordinate
  deltadir(ml,u,v,w)  sector difference btw adjacent egdes uv and uw as measure of angle btw;

*INTEGER VARIABLES
*;


POSITIVE VARIABLES
  x(u)      x coordinate
  y(u)      y coordinate
  z1(u)     +45 degree coordinate
  dir(u,v)         octilinear direction of edge uv
*  lambda(u,v)      upper bound on edge length
*  costS1           total line bend cost
*  costS2           total relative position cost
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
*  obj
;

$ontext
sets     j9(u) /32,10,31,8/
         j11(u) /48,12,47,10/
         j19(u) /20,42,18,41/
         j35(u) /36,52,62,34,73/
         j37(u) /38,53,36,54/
         j38(u) /74,39,52,37/
         j39(u) /65,40,64,38/
         j50(u) /51,63,49,62/
         j52(u) /53,38,51,35/
         j66(u) /67,75,65,74/
$offtext

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

$ontext
telcon1(u,v)$f(u,v)..  x(u) - x(v) =l= lambda(u,v);
telcon2(u,v)$f(u,v).. -x(u) + x(v) =l= lambda(u,v);
telcon3(u,v)$f(u,v)..  y(u) - y(v) =l= lambda(u,v);
telcon4(u,v)$f(u,v).. -y(u) + y(v) =l= lambda(u,v);
$offtext

$ontext
*OBJECTIVE
objbend.. cs1 =e= sum(ml, sum( (u,v,w), bd(ml,u,v,w) )  );
objrpos.. cs2 =e= sum(e1, rpos(e1));
*objtel..  z('edgelength') =e= sum(f, lambda(f));
obj.. Z =e= weight('1')*cs1 + weight('2')*cs2 ;
$offtext

* Changed condition on inner sum so only line edges were accounted for in bend cost 8/8/14
objbend.. z('bend') =e= sum(ml, sum( (u,v,w)$(lin(u,v,ml) and lin(v,w,ml)), bd(ml,u,v,w) )  );
objrpos.. z('rposition') =e= sum(e1, rpos(e1));
*objtel..  z('edgelength') =e= sum(f, lambda(f));
*obj.. Z =e= weight('1')*z('bend') + weight('2')*z('rposition') ;


*x.fx('1') = 6.2;
*x.fx('8') = 12.2;
*x.lo()
*=========================================================================
*                               MODEL
*=========================================================================
MODEL automap /   xlim, ylim
                  defz1
                  defz2
                  octicon1
                  octicon2a
                  octicon2b
                  octicon3a, octicon3b, octicon3c
                  octicon3d, octicon3e, octicon3f
                  octicon3g, octicon3h, octicon3i
                  octicon3j, octicon3k, octicon3l
                  octicon3m, octicon3n, octicon3o
                  octicon3p, octicon3q, octicon3r
                  octicon3s, octicon3t, octicon3u
                  octicon3v, octicon3w, octicon3x
                  cvocon1
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
*$ONTEXT
                  edgecon
                  edgeconE1,  edgeconE2,  edgeconE3,  edgeconE4
                  edgeconNE1, edgeconNE2, edgeconNE3, edgeconNE4
                  edgeconN1,  edgeconN2,  edgeconN3,  edgeconN4
                  edgeconNW1, edgeconNW2, edgeconNW3, edgeconNW4
                  edgeconW1,  edgeconW2,  edgeconW3,  edgeconW4
                  edgeconSW1, edgeconSW2, edgeconSW3, edgeconSW4
                  edgeconS1,  edgeconS2,  edgeconS3,  edgeconS4
                  edgeconSE1, edgeconSE2, edgeconSE3, edgeconSE4
*$OFFTEXT
                  telcon1, telcon2, telcon3, telcon4
                  rposcon1, rposcon2
                  bendcon1, bendcon2
                  ddi
                  objbend, objrpos
                  /;


*$ontext
*=========================================================================
*                         CONSTRAINT METHOD
*=========================================================================
$STitle eps-constraint method

Set k1(k)  the first element of k,
    km1(k) all but the first elements of k
    kk(k)  active objective function in constraint allobj;
k1(k)$(ord(k)=1) = yes; km1(k)=yes; km1(k1) = no;

Parameter
    rhs(k)     right hand side of the constrained obj functions in eps-constraint
    maxobj(k)  maximum value from the payoff table
    minobj(k)  minimum value from the payoff table
    numk(k)    ordinal value of k starting with 1
Scalar
    iter         total number of iterations
    infeas       total number of infeasibilities
    elapsed_time elapsed time for payoff and e-sonstraint
    start        start time
    finish       finish time
Variables
   a_objval   auxiliary variable for the objective function
   obj        auxiliary variable during the construction of the payoff table
   sl(k)      slack or surplus variables for the eps-constraints
Positive Variables sl
Equations
   con_obj(k) constrained objective functions
   augm_obj   augmented objective function to avoid weakly efficient solutions
   allobj     all the objective functions in one expression;

con_obj(km1)..   z(km1) + sl(km1) =e= rhs(km1);

* We optimize the first objective function and put the others as constraints
* the second term is for avoiding weakly efficient points

augm_obj.. a_objval =e= sum(k1, z(k1))
    - 1e-3*sum(km1,power(10,-(numk(km1)-1))*sl(km1)/(maxobj(km1)-minobj(km1)));

allobj..  sum(kk, z(kk)) =e= obj;

Model mod_payoff    / automap, allobj / ;
Model mod_epsmethod / automap, con_obj, augm_obj / ;

Parameter
   payoff(k,k)  payoff tables entries;
Alias(k,kp);

option threads=4, optcr=0, limrow=0, limcol=0, solprint=off, solvelink=%Solvelink.LoadLibrary%;

* Generate payoff table applying lexicographic optimization
loop(kp,
  kk(kp)=yes;
  repeat
    solve mod_payoff using mip minimizing obj;
    payoff(kp,kk) = z.l(kk);
    z.fx(kk) = z.l(kk); // freeze the value of the last objective optimized
    kk(k++1) = kk(k);   // cycle through the objective functions
  until kk(kp); kk(kp) = no;
* release the fixed values of the objective functions for the new iteration
  z.up(k) = inf; z.lo(k) =-inf;
);
if (mod_payoff.modelstat<>%ModelStat.Optimal% and
    mod_payoff.modelstat<>%ModelStat.Integer Solution%,
   abort 'no optimal solution for mod_payoff');

file fx  / vienna_results.txt /;
***
*** File holding coordinates
file pareto / viennafrontier.csv /;     put pareto 'x1'',', 'x2'',','y1'',', 'y2'',','ln'',','co'/;
put fx ' PAYOFF TABLE'/   ;
loop (kp,
   loop(k, put payoff(kp,k):12:2);
   put /);

minobj(k)=smin(kp,payoff(kp,k));
maxobj(k)=smax(kp,payoff(kp,k));

* gridpoints are calculated as the range (difference between max and min) of
* the 2nd objective function from the payoff table
$if not set gridpoints $set gridpoints 38
Set g            grid points /g0*g%gridpoints%/
    grid(k,g)    grid
Parameter
    gridrhs(k,g) rhs of eps-constraint at grid point
    maxg(k)      maximum point in grid for objective
    posg(k)      grid position of objective
    firstOffMax, lastZero some counters
*    numk(k) ordinal value of k starting with 1
    numg(g)      ordinal value of g starting with 0
    step(k)      step of grid points in objective functions
    jump(k)      jumps in the grid points traversing;

lastZero=1; loop(km1, numk(km1)=lastZero; lastZero=lastZero+1); numg(g) = ord(g)-1;

grid(km1,g) = yes; // Here we could define different grid intervals for different objectives
maxg(km1)   = smax(grid(km1,g), numg(g));
step(km1)   = (maxobj(km1)- minobj(km1))/maxg(km1);
gridrhs(grid(km1,g))  = maxobj(km1) - numg(g)/maxg(km1)*(maxobj(km1)- minobj(km1));


put / ' Grid points' /;
loop (g,
   loop(km1, put gridrhs(km1,g):12:2);
   put /);
put / 'Efficient solutions' /;

* Walk the grid points and take shortcuts if the model becomes infeasible or
* if the calculated slack variables are greater than the step size
posg(km1) = 0; iter=0; infeas=0; start=jnow;

repeat
  put fx ;
  rhs(km1) = sum(grid(km1,g)$(numg(g)=posg(km1)), gridrhs(km1,g));
  solve mod_epsmethod minimizing a_objval using mip;
  iter=iter+1;
  if (mod_epsmethod.modelstat<>%ModelStat.Optimal% and
      mod_epsmethod.modelstat<>%ModelStat.Integer Solution%,
    infeas=infeas+1;   // not optimal is in this case infeasible
    put iter:5:0, '  infeasible' /;
    lastZero = 0; loop(km1$(posg(km1)>0 and lastZero=0), lastZero=numk(km1));
    posg(km1)$(numk(km1)<=lastZero) = maxg(km1); // skip all solves for more demanding values of rhs(km1)
  else
    put fx iter:5:0;
    loop(k, put fx z.l(k):12:2);
    jump(km1)=1;
*   find the first off max (obj function that hasn't reach the final grid point).
*   If this obj.fun is k then assign jump for the 1..k-th objective functions
*   The jump is calculated for the innermost objective function (km=1)
    jump(km1)$(numk(km1)=1)=1+floor(sl.L(km1)/step(km1));
    loop(km1$(jump(km1)>1), put '   jump');
    put /;
*   coordinate file
    put  pareto ;
    pareto.lj=1;
    loop((ml,u,v), put$(lin(u,v,ml)) x.l(u)',', x.l(v)',',y.l(u)',',y.l(v)',', ord(ml)',', ml.te(ml)/);
    );
* Proceed forward in the grid
  firstOffMax = 0;
  loop(km1$(posg(km1)<maxg(km1) and firstOffMax=0),
     posg(km1)=min((posg(km1)+jump(km1)),maxg(km1)); firstOffMax=numk(km1));
  posg(km1)$(numk(km1)<firstOffMax) = 0;
until sum(km1$(posg(km1)=maxg(km1)),1)= card(km1) and firstOffMax=0;

finish=jnow; elapsed_time=(finish-start)*60*60*24;
put fx;
put /;
put 'Infeasibilities = ', infeas:5:0 /;
put 'Elapsed time: ',elapsed_time:10:2, ' seconds' / ;


*display x.l;

*$offtext