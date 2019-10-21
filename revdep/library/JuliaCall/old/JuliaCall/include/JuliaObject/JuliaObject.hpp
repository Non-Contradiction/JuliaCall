#ifndef JuliaObject__JuliaObject__hpp
#define JuliaObject__JuliaObject__hpp

#include <RcppCommon.h>

class JuliaObject{
public:
    SEXP x;
    JuliaObject();
    JuliaObject(SEXP);
    operator SEXP();
};

#include <Rcpp.h>
using namespace Rcpp;

Function init_jcall(){
    Environment base = Environment("package:base");
    Function eval = base["eval"];
    Function parse = base["parse"];
    return eval(parse("", -1, "JuliaCall::julia_call"));
}

const Function jcall = init_jcall();

JuliaObject::JuliaObject(SEXP x1){
    x = jcall("JuliaCall.JuliaObject", x1);
};

SEXP wrap(JuliaObject j){
    return SEXP(j.x);
}

#define UNARY_FUNC(fname, jname) JuliaObject fname(JuliaObject j){return jcall(#jname, j);}

#define BINARY_FUNC(fname, jname) JuliaObject fname(JuliaObject j1, JuliaObject j2){return jcall(#jname, j1, j2);}

UNARY_FUNC(log, log.);

UNARY_FUNC(sqrt, sqrt.);

UNARY_FUNC(sum, sum);

#endif // hinterface__hinterface__hpp
