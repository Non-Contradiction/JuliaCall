context("DAEs")

test_that('DAEs work',{

  skip_on_cran()

  diffeqr::diffeq_setup()

  f <- function (du,u,p,t) {
    resid1 = - 0.04*u[1]              + 1e4*u[2]*u[3] - du[1]
    resid2 = + 0.04*u[1] - 3e7*u[2]^2 - 1e4*u[2]*u[3] - du[2]
    resid3 = u[1] + u[2] + u[3] - 1.0
    c(resid1,resid2,resid3)
  }
  u0 = c(1.0, 0, 0)
  du0 = c(-0.04, 0.04, 0.0)
  tspan = list(0.0,100000.0)
  differential_vars = c(TRUE,TRUE,FALSE)
  sol = diffeqr::dae.solve(f,du0,u0,tspan,differential_vars=differential_vars)
  udf = as.data.frame(sol$u)
  #plotly::plot_ly(udf, x = sol$t, y = ~V1, type = 'scatter', mode = 'lines') %>%
  #plotly::add_trace(y = ~V2) %>%
  #plotly::add_trace(y = ~V3)

  f = JuliaCall::julia_eval("function f(out,du,u,p,t)
    out[1] = - 0.04u[1]              + 1e4*u[2]*u[3] - du[1]
    out[2] = + 0.04u[1] - 3e7*u[2]^2 - 1e4*u[2]*u[3] - du[2]
    out[3] = u[1] + u[2] + u[3] - 1.0
  end")
  sol = diffeqr::dae.solve('f',du0,u0,tspan,differential_vars=differential_vars)
  expect_true(length(sol$t) < 200)
})
