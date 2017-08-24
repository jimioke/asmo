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

$oninline
$inlinecom [ ]
$eolcom //

$set stepsum = 1;

scalar starttime; starttime = jnow; // current time

*=========================================================================
*                                  DATA
*=========================================================================
SETS
u           "vertices"           /1*11/
b(u)        "subset of vertices with more than one spanning edge"
ml          "metro lines"        / 1  "r"
                                   2  "g"
                                   3  "b"
                                   4  "DarkOrange"
                                   /
r           "relative position"  / prec, orig, succ /
c           "compass directions" / N, S, E, W, NE, NW, SE, SW /
e(u,u)      "edges as directed and undirected pairs"
f(u,u)      "undirected edges"
g(u,u)      "opposite directed edge"
n(u,u,u,u)  "nonincident edges"
S           "cost factors"       /1*3/
j(u,u)      "set of degrees"
 ;

Alias (u, v, w, ww);

Scalars
        M     "maximum length or width of map" / 52 /
        lmin  "minimum edge length"            / 2 /
        dmin  "minimum edge distance"          / 1 /
        ;

PARAMETERS
    deg(u)  degree  /1   1
                     2   3
                     3   4
                     4   4
                     5   4
                     6   1
                     7   2
                     8   2
                     9   2
                     10  2
                     11  1
                     /

* 1: bend cost,  2: relative position cost,   3: total edge length
    weight(S) weights / 1  .5
                        2  .5
                        3  .2 / ;


* Specifying vertices subject to the circular vertex order constraint (H2)
* Condition: degree of vertex must be greater than 2
b(u)=yes$(deg(u) ge 2);


* INCIDENCES
TABLE   order(u,v) ordered vertex neighbor incidence
        1  2  3  4  5  6  7  8  9  10 11
    1
    2   1     1  1
    3      1     1  1              1
    4      1  1     1        1
    5         1  1     1  1
    6
    7               1           1
    8            1              1
    9                     1  1
    10        1                       1
    11
    ;

j(u,v)=yes$order(u,v)  ;

TABLE   path(u,v) directed path incidence
        1  2  3  4  5  6  7  8  9  10 11
    1      1
    2   1     1  1
    3      1     1  1              1
    4      1  1     1        1
    5         1  1     1  1
    6               1
    7               1           1
    8            1              1
    9                     1  1
    10        1                       1
    11                             1
    ;

TABLE   upath(u,v) undirected path incidence
        1  2  3  4  5  6  7  8  9  10 11
    1      1
    2         1  1
    3               1              1
    4         1     1
    5                  1  1
    6
    7
    8            1
    9                     1  1
    10                                1
    11
    ;

TABLE   opath(u,v) directed path incidence (opposite sense)
        1  2  3  4  5  6  7  8  9  10 11
    1
    2   1
    3      1     1
    4      1                 1
    5         1  1
    6               1
    7               1           1
    8                           1
    9
    10        1
    11                             1
    ;

* Define edges
e(u,v) = yes$path(u,v);
f(u,v) = yes$upath(u,v);
g(u,v) = yes$opath(u,v);


TABLE   e2e(u,v,w,ww) edge-to-edge incidence
          1.2   2.3   2.4   3.4   3.5   3.10  4.3   4.5   5.6   5.7   8.4   9.7   9.8   10.11
    1.2         1     1
    2.3                     1     1     1
    2.4                                       1     1
    3.5                                                   1     1
    3.10                                                                                1
    4.3         1                 1     1           1
    4.5                           1                       1     1
    5.6
    5.7
    8.4
    9.7
    9.8
    10.11

TABLE   ne2e(u,v,w,ww) edge-to-edge non-incidence same face
          1.2   2.3   2.4   3.4   3.5   3.10  4.3   4.5   5.6   5.7   8.4   9.7   9.8   10.11
    1.2                                 1                 1                             1
    2.3
    2.4
    3.5
    3.10
    4.3
    4.5                                                                     1     1
    5.6
    5.7
    8.4                                                         1           1
    9.7
    9.8                                                         1
    10.11
    ;

* Define nonincident edges
n(u,v,w,ww) = yes$ne2e(u,v,w,ww);

TABLE   sec(r,u,v) sector positioning
            1   2   3   4   5   6   7   8   9   10  11
    orig.1      0
    orig.2  4       2   1
    orig.3      6       7   0                   4
    orig.4      5   3       2           7
    orig.5          4   6       1   0
    orig.6                  5
    orig.7                  4               6
    orig.8              3                   0
    orig.9                          2   4
    orig.10         0                                2
    orig.11                                     6
    prec.1      7
    prec.2  3       1   0
    prec.3      5       6   7                   3
    prec.4      4   2       1           6
    prec.5          3   5       0   7
    prec.6                  4
    prec.7                  3               5
    prec.8              2                   7
    prec.9                          1   3
    prec.10         7                                1
    prec.11                                     5
    succ.1      1
    succ.2  5       3   2
    succ.3      7       0   1                   5
    succ.4      6   4       3           0
    succ.5          5   7       2   1
    succ.6                  6
    succ.7                  5               7
    succ.8              4                   1
    succ.9                          3   5
    succ.10         1                                3
    succ.11                                     7

TABLE   lin(ml,u,v)  metro lines
         1.2   2.3   2.4   3.5   3.10  4.3   4.5   5.6   5.7   8.4   9.7   9.8   10.11
    1    1           1                       1     1
    2          1           1                             1
    3                            1     1                       1           1     1
    4                                                                1
    ;

* TABLE   lin2(ml,u) stations per line
*          1   2   3   4   5   6   7   8   9   10  11
*     1    1   1       1   1   1
*     2        1   1       1       1
*     3            1   1               1   1   1   1
*     4                            1       1
* ;

*=========================================================================
*                                VARIABLES
*=========================================================================
VARIABLES
  Z         total cost
  z2(u)     -45 degree coordinate
  deltadir(ml,u,v,w)  sector difference btw adjacent egdes uv and uw as measure of angle btw;

INTEGER VARIABLES
  x(u)      x coordinate
  y(u)      y coordinate
;


POSITIVE VARIABLES
  z1(u)     +45 degree coordinate
  dir(u,v)         octilinear direction of edge uv
  lambda(u,v)      upper bound on edge length
  costS1           total line bend cost
  costS2           total relative position cost
  costS3           total edge length cost
  bd(ml,u,v,w)        bend cost of angle between uv and vw
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
  cvocon2a, cvocon2b, cvocon2c,
  cvocon3a, cvocon3b, cvocon3c, cvocon3d
  cvocon4a, cvocon4b, cvocon4c, cvocon4d
  cvocon5a, cvocon5b, cvocon5c, cvocon5d
  cvocon7a, cvocon7b
  cvocon8a, cvocon8b
  cvocon9a, cvocon9b
  cvocon10a, cvocon10b
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
  cs1
  cs2
  cs3
  obj;

* Map limits
xlim(u).. x(u) =l= M;
ylim(u).. y(u) =l= M;

* Z coordinates
defz1(u).. z1(u) =e= (x(u) + y(u))/2;
defz2(u).. z2(u) =e= (x(u) - y(u))/2;

* Octilinearity constraints  (H1, H3)
octicon1(u,v)$f(u,v)..     sum(r, alpha(u,v,r)) =e= 1;
octicon2a(u,v)$f(u,v)..    dir(u,v) =e= sum(r,(sec(r,u,v)*alpha(u,v,r))) ;
octicon2b(u,v)$g(u,v)..    dir(u,v) =e= sum(r,(sec(r,u,v)*alpha(v,u,r))) ;

octicon3a(r,u,v)$(sec(r,u,v)=0 and f(u,v))..   y(u) - y(v) =l=  M*(1-alpha(u,v,r));
octicon3b(r,u,v)$(sec(r,u,v)=0 and f(u,v))..  -y(u) + y(v) =l=  M*(1-alpha(u,v,r));
octicon3c(r,u,v)$(sec(r,u,v)=0 and f(u,v))..  -x(u) + x(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3d(r,u,v)$(sec(r,u,v)=1 and f(u,v))..   z2(u) - z2(v) =l=  M*(1-alpha(u,v,r));
octicon3e(r,u,v)$(sec(r,u,v)=1 and f(u,v))..  -z2(u) + z2(v) =l=  M*(1-alpha(u,v,r));
octicon3f(r,u,v)$(sec(r,u,v)=1 and f(u,v))..  -z1(u) + z1(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3g(r,u,v)$(sec(r,u,v)=2 and f(u,v))..   x(u) - x(v) =l=  M*(1-alpha(u,v,r));
octicon3h(r,u,v)$(sec(r,u,v)=2 and f(u,v))..  -x(u) + x(v) =l=  M*(1-alpha(u,v,r));
octicon3i(r,u,v)$(sec(r,u,v)=2 and f(u,v))..  -y(u) + y(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3j(r,u,v)$(sec(r,u,v)=3 and f(u,v))..   z1(u) - z1(v) =l=  M*(1-alpha(u,v,r));
octicon3k(r,u,v)$(sec(r,u,v)=3 and f(u,v))..  -z1(u) + z1(v) =l=  M*(1-alpha(u,v,r));
octicon3l(r,u,v)$(sec(r,u,v)=3 and f(u,v))..   z2(u) - z2(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3m(r,u,v)$(sec(r,u,v)=4 and f(u,v))..   y(u) - y(v) =l=  M*(1-alpha(u,v,r));
octicon3n(r,u,v)$(sec(r,u,v)=4 and f(u,v))..  -y(u) + y(v) =l=  M*(1-alpha(u,v,r));
octicon3o(r,u,v)$(sec(r,u,v)=4 and f(u,v))..   x(u) - x(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3p(r,u,v)$(sec(r,u,v)=5 and f(u,v))..   z2(u) - z2(v) =l=  M*(1-alpha(u,v,r));
octicon3q(r,u,v)$(sec(r,u,v)=5 and f(u,v))..  -z2(u) + z2(v) =l=  M*(1-alpha(u,v,r));
octicon3r(r,u,v)$(sec(r,u,v)=5 and f(u,v))..   z1(u) - z1(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3s(r,u,v)$(sec(r,u,v)=6 and f(u,v))..   x(u) - x(v) =l=  M*(1-alpha(u,v,r));
octicon3t(r,u,v)$(sec(r,u,v)=6 and f(u,v))..  -x(u) + x(v) =l=  M*(1-alpha(u,v,r));
octicon3u(r,u,v)$(sec(r,u,v)=6 and f(u,v))..   y(u) - y(v) =g= -M*(1-alpha(u,v,r)) + lmin;

octicon3v(r,u,v)$(sec(r,u,v)=7 and f(u,v))..   z1(u) - z1(v) =l=  M*(1-alpha(u,v,r));
octicon3w(r,u,v)$(sec(r,u,v)=7 and f(u,v))..  -z1(u) + z1(v) =l=  M*(1-alpha(u,v,r));
octicon3x(r,u,v)$(sec(r,u,v)=7 and f(u,v))..  -z2(u) + z2(v) =g= -M*(1-alpha(u,v,r)) + lmin;


* Circular vertex orders (H2)
cvocon1(b).. sum(v, beta(b,v)$j(b,v)) =e= 1;

cvocon2a.. dir('2','4') =l= dir('2','3')  - 1 + 8*beta('2','4');
cvocon2b.. dir('2','3') =l= dir('2','1')  - 1 + 8*beta('2','3');
cvocon2c.. dir('2','1') =l= dir('2','4')  - 1 + 8*beta('2','1');

cvocon3a.. dir('3','5') =l= dir('3','10')  - 1 + 8*beta('3','5');
cvocon3b.. dir('3','10') =l= dir('3','2')  - 1 + 8*beta('3','10');
cvocon3c.. dir('3','2') =l= dir('3','4')  - 1 + 8*beta('3','2');
cvocon3d.. dir('3','4') =l= dir('3','5')  - 1 + 8*beta('3','4');


cvocon4a.. dir('4','5') =l= dir('4','3')  - 1 + 8*beta('4','5');
cvocon4b.. dir('4','3') =l= dir('4','2')  - 1 + 8*beta('4','3');
cvocon4c.. dir('4','2') =l= dir('4','8')  - 1 + 8*beta('4','2');
cvocon4d.. dir('4','8') =l= dir('4','5')  - 1 + 8*beta('4','8');

cvocon5a.. dir('5','7') =l= dir('5','6')  - 1 + 8*beta('5','7');
cvocon5b.. dir('5','6') =l= dir('5','3')  - 1 + 8*beta('5','6');
cvocon5c.. dir('5','3') =l= dir('5','4')  - 1 + 8*beta('5','3');
cvocon5d.. dir('5','4') =l= dir('5','7')  - 1 + 8*beta('5','4');

cvocon7a.. dir('7','5') =l= dir('7','9')  - 1 + 8*beta('7','5');
cvocon7b.. dir('7','9') =l= dir('7','5')  - 1 + 8*beta('7','9');

cvocon8a.. dir('8','9') =l= dir('8','4')  - 1 + 8*beta('8','9');
cvocon8b.. dir('8','4') =l= dir('8','9')  - 1 + 8*beta('8','4');

cvocon9a.. dir('9','7') =l= dir('9','8')  - 1 + 8*beta('9','7');
cvocon9b.. dir('9','8') =l= dir('9','7')  - 1 + 8*beta('9','8');

cvocon10a.. dir('10','3') =l= dir('10','11')  - 1 + 8*beta('10','3');
cvocon10b.. dir('10','11') =l= dir('10','3')  - 1 + 8*beta('10','11');

* Edge spacing constraints (H4)
edgecon(n).. sum(c, gamma(n,c)) =g= 1;

edgeconE1(u,v,w,ww)$n(u,v,w,ww).. x(w) - x(u)  =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE2(u,v,w,ww)$n(u,v,w,ww).. x(w) - x(v)  =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE3(u,v,w,ww)$n(u,v,w,ww).. x(ww) - x(u) =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;
edgeconE4(u,v,w,ww)$n(u,v,w,ww).. x(ww) - x(v) =l= M*(1 - gamma(u,v,w,ww,'E')) - dmin ;

edgeconNE1(u,v,w,ww)$n(u,v,w,ww).. z1(w) - z1(u)  =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE2(u,v,w,ww)$n(u,v,w,ww).. z1(w) - z1(v)  =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE3(u,v,w,ww)$n(u,v,w,ww).. z1(ww) - z1(u) =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;
edgeconNE4(u,v,w,ww)$n(u,v,w,ww).. z1(ww) - z1(v) =l= M*(1 - gamma(u,v,w,ww,'NE')) - dmin ;

edgeconN1(u,v,w,ww)$n(u,v,w,ww).. y(w) - y(u)  =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN2(u,v,w,ww)$n(u,v,w,ww).. y(w) - y(v)  =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN3(u,v,w,ww)$n(u,v,w,ww).. y(ww) - y(u) =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;
edgeconN4(u,v,w,ww)$n(u,v,w,ww).. y(ww) - y(v) =l= M*(1 - gamma(u,v,w,ww,'N')) - dmin ;

edgeconNW1(u,v,w,ww)$n(u,v,w,ww).. -z2(w) + z2(u)  =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW2(u,v,w,ww)$n(u,v,w,ww).. -z2(w) + z2(v)  =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW3(u,v,w,ww)$n(u,v,w,ww).. -z2(ww) + z2(u) =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;
edgeconNW4(u,v,w,ww)$n(u,v,w,ww).. -z2(ww) + z2(v) =l= M*(1 - gamma(u,v,w,ww,'NW')) - dmin ;

edgeconW1(u,v,w,ww)$n(u,v,w,ww).. -x(w) + x(u)  =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW2(u,v,w,ww)$n(u,v,w,ww).. -x(w) + x(v)  =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW3(u,v,w,ww)$n(u,v,w,ww).. -x(ww) + x(u) =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;
edgeconW4(u,v,w,ww)$n(u,v,w,ww).. -x(ww) + x(v) =l= M*(1 - gamma(u,v,w,ww,'W')) - dmin ;

edgeconSW1(u,v,w,ww)$n(u,v,w,ww).. -z1(w) + z1(u)  =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW2(u,v,w,ww)$n(u,v,w,ww).. -z1(w) + z1(v)  =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW3(u,v,w,ww)$n(u,v,w,ww).. -z1(ww) + z1(u) =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;
edgeconSW4(u,v,w,ww)$n(u,v,w,ww).. -z1(ww) + z1(v) =l= M*(1 - gamma(u,v,w,ww,'SW')) - dmin ;

edgeconS1(u,v,w,ww)$n(u,v,w,ww).. -y(w) + y(u)  =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS2(u,v,w,ww)$n(u,v,w,ww).. -y(w) + y(v)  =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS3(u,v,w,ww)$n(u,v,w,ww).. -y(ww) + y(u) =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;
edgeconS4(u,v,w,ww)$n(u,v,w,ww).. -y(ww) + y(v) =l= M*(1 - gamma(u,v,w,ww,'S')) - dmin ;

edgeconSE1(u,v,w,ww)$n(u,v,w,ww).. z2(w) - z2(u)  =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE2(u,v,w,ww)$n(u,v,w,ww).. z2(w) - z2(v)  =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE3(u,v,w,ww)$n(u,v,w,ww).. z2(ww) - z2(u) =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;
edgeconSE4(u,v,w,ww)$n(u,v,w,ww).. z2(ww) - z2(v) =l= M*(1 - gamma(u,v,w,ww,'SE')) - dmin ;


* Line Bends (S1 - soft constraint 1)
ddi(ml,u,v,w)$(lin(ml,u,v) and lin(ml,v,w)).. deltadir(ml,u,v,w) =e= dir(u,v) - dir(v,w);

*$(f(u,v) and f(v,w))

* Bend constraints
bendcon1(ml,u,v,w)$(lin(ml,u,v) and lin(ml,v,w))..  bd(ml,u,v,w) =g= deltadir(ml,u,v,w) - 8*delta1(ml,u,v,w) + 8*delta2(ml,u,v,w);
bendcon2(ml,u,v,w)$(lin(ml,u,v) and lin(ml,v,w)).. -bd(ml,u,v,w) =l= deltadir(ml,u,v,w) - 8*delta1(ml,u,v,w) + 8*delta2(ml,u,v,w);

* Relative position constraint S2
rposcon1(f)..   M*rpos(f) =g= dir(f) - sec('orig',f);
rposcon2(f)..  -M*rpos(f) =l= dir(f) - sec('orig',f);


* Total edge length S3 constraints
telcon1(u,v)$f(u,v)..  x(u) - x(v) =l= lambda(u,v);
telcon2(u,v)$f(u,v).. -x(u) + x(v) =l= lambda(u,v);
telcon3(u,v)$f(u,v)..  y(u) - y(v) =l= lambda(u,v);
telcon4(u,v)$f(u,v).. -y(u) + y(v) =l= lambda(u,v);


* Total bend cost (S1)
cs1.. costS1 =e= sum(  ml,  sum( (u,v,w), bd(ml,u,v,w) )  );

* Relative position cost (S2)
cs2.. costS2 =e= sum(f, rpos(f));

* Total edge length (S3)
cs3.. costS3 =e= sum(f, lambda(f));

*OBJECTIVE
obj.. Z =e= weight('1')*costS1 + weight('2')*costS2 + weight('3')*costS3;


*x.fx('1') = 0;
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
                  cvocon2a, cvocon2b, cvocon2c,
                  cvocon3a, cvocon3b, cvocon3c, cvocon3d
                  cvocon4a, cvocon4b, cvocon4c, cvocon4d
                  cvocon5a, cvocon5b, cvocon5c, cvocon5d
                  cvocon7a, cvocon7b
                  cvocon8a, cvocon8b
                  cvocon9a, cvocon9b
                  cvocon10a, cvocon10b
                  edgecon
                  edgeconE1,  edgeconE2,  edgeconE3,  edgeconE4
                  edgeconNE1, edgeconNE2, edgeconNE3, edgeconNE4
                  edgeconN1,  edgeconN2,  edgeconN3,  edgeconN4
                  edgeconNW1, edgeconNW2, edgeconNW3, edgeconNW4
                  edgeconW1,  edgeconW2,  edgeconW3,  edgeconW4
                  edgeconSW1, edgeconSW2, edgeconSW3, edgeconSW4
                  edgeconS1,  edgeconS2,  edgeconS3,  edgeconS4
                  edgeconSE1, edgeconSE2, edgeconSE3, edgeconSE4
                  telcon1, telcon2, telcon3, telcon4
                  rposcon1, rposcon2
                  bendcon1, bendcon2
                  obj
                  ddi
                  cs1, cs2, cs3
                  /;

* Ensure proven optimal solutions!
* automap.OptCR = 0;

*option mip=bdmlp;

SOLVE automap minimizing Z using MIP;

Display x.l, y.l,alpha.l, dir.l, beta.l, bd.l, costS1.l, costS2.l,  Z.l;



file coords /coordinates.csv/ ;
put  coords ;
coords.lj=1; [label justification, left]
put 'x1'',', 'x2'',','y1'',', 'y2'',','ln'',','co'/;
loop((ml,u,v), put$(lin(ml,u,v)) x.l(u)',', x.l(v)',',y.l(u)',',y.l(v)',', ord(ml)',', ml.te(ml)/);
putclose coords ;

scalar elapsed; elapsed = (jnow - starttime)*24*3600;
display elapsed;
