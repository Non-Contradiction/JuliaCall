context("SDEs")

test_that('1D works',{

  skip_on_cran()

  f <- function(u,p,t) {
    return(1.01*u)
  }
  g <- function(u,p,t) {
    return(0.87*u)
  }
  u0 = 1/2
  tspan <- list(0.0,1.0)
  sol = diffeqr::sde.solve(f,g,u0,tspan)

  expect_true(length(sol$t) > 10)
})

test_that('seed works',{

  skip_on_cran()

  f <- function(u,p,t) {
    return(1.01*u)
  }
  g <- function(u,p,t) {
    return(0.87*u)
  }
  u0 = 1/2
  tspan <- list(0.0,1.0)
  sol = diffeqr::sde.solve(f,g,u0,tspan,seed=1)
  sol2 = diffeqr::sde.solve(f,g,u0,tspan,seed=1)
  expect_true(sum(sol$u - sol2$u) == 0)
})
#plot(sol$t,sol$u,"l")
#plotly::plot_ly(x = sol$t, y = sol$u, type = 'scatter', mode = 'lines')

test_that('diagonal noise works',{

  skip_on_cran()

  f <- function(u,p,t) {
    du1 = p[1]*(u[2]-u[1])
    du2 = u[1]*(p[2]-u[3]) - u[2]
    du3 = u[1]*u[2] - p[3]*u[3]
    return(c(du1,du2,du3))
  }
  g <- function(u,p,t) {
    return(c(0.3*u[1],0.3*u[2],0.3*u[3]))
  }
  u0 = c(1.0,0.0,0.0)
  tspan <- list(0.0,1.0)
  p = c(10.0,28.0,8/3)
  sol = diffeqr::sde.solve(f,g,u0,tspan,p=p,saveat=0.05)
  expect_equal(length(sol$t),21)
  udf = as.data.frame(sol$u)
  #plotly::plot_ly(udf, x = ~V1, y = ~V2, z = ~V3, type = 'scatter3d', mode = 'lines')

  f <- JuliaCall::julia_eval("
  function f(du,u,p,t)
    du[1] = 10.0*(u[2]-u[1])
    du[2] = u[1]*(28.0-u[3]) - u[2]
    du[3] = u[1]*u[2] - (8/3)*u[3]
  end")

  g <- JuliaCall::julia_eval("
  function g(du,u,p,t)
    du[1] = 0.3u[1]
    du[2] = 0.3u[2]
    du[3] = 0.3u[3]
  end")
  tspan <- list(0.0,100.0)
  sol = diffeqr::sde.solve('f','g',u0,tspan,p=p,saveat=0.05)
  expect_equal(length(sol$t),2001)
  udf = as.data.frame(sol$u)
  #plotly::plot_ly(udf, x = ~V1, y = ~V2, z = ~V3, type = 'scatter3d', mode = 'lines')
})

test_that('non-diagonal noise works',{

  skip_on_cran()

  f <- JuliaCall::julia_eval("
  function f(du,u,p,t)
    du[1] = 10.0*(u[2]-u[1])
    du[2] = u[1]*(28.0-u[3]) - u[2]
    du[3] = u[1]*u[2] - (8/3)*u[3]
  end")

  g <- JuliaCall::julia_eval("
  function g(du,u,p,t)
    du[1,1] = 0.3u[1]
    du[2,1] = 0.6u[1]
    du[3,1] = 0.2u[1]
    du[1,2] = 1.2u[2]
    du[2,2] = 0.2u[2]
    du[3,2] = 0.3u[2]
  end")
  u0 = c(1.0,0.0,0.0)
  tspan <- list(0.0,100.0)
  noise.dims = list(3,2)
  sol = diffeqr::sde.solve('f','g',u0,tspan,saveat=0.005,noise.dims=noise.dims)
  expect_equal(length(sol$t),20001)
  udf = as.data.frame(sol$u)
  #plotly::plot_ly(udf, x = ~V1, y = ~V2, z = ~V3, type = 'scatter3d', mode = 'lines')
})
