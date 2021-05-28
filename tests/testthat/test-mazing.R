test_that("basic maze functionality works", {
    m <- maze(10,10)
    expect_true(is.matrix(m))
    expect_true(is.maze(m))
    
    m <- matrix(1, nrow = 10, ncol = 10)
    expect_true(is.matrix(m))
    expect_false(is.maze(m))
    m <- as.maze(m)
    expect_true(is.maze(m))
    
    
})

test_that("pathfinding works as expected", {
    m <- maze(10,10)
    p <- solve_maze(m)
    expect_true(is.matrix(p))
    
    p2 <- solve_maze(m, start = c(1,1), end = c(10,10))
    expect_identical(p, p2)
    
    p3 <- solve_maze(m, start = 'mbottomleft', end = 'mrighttop')
    expect_identical(p, p3)
    
    m <- matrix(1, nrow = 10, ncol = 10)
    m <- cbind(m, 0,0,0, m)
    m <- as.maze(m)
    expect_error(solve_maze(m),
                 "path between 'start' and 'end' could not be found")
})

test_that("plotting functions do not give errors", {
    m <- maze(10, 10)
    expect_invisible(plot(m))
    expect_invisible(plot(m, walls = TRUE))
    expect_invisible(plot(m, adjust = c(.5,.5)))
    expect_invisible(plot(m, walls = TRUE, adjust = c(.5,.5)))
})

test_that("advanced maze/matrix manipulation works", {
    m <- maze(10, 10)
    m <- maze2binary(m)
    expect_true(is.matrix(m))
})