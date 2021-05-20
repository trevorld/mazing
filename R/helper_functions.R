

# key:
# 0 = origin, 1 = down, 2 = left, 3 = up, 4 = right
# -1 = to be filled in
# -5 = not to be filled in

adjacent <- function(coords, maze, return.coords = FALSE){
    out.coords <- NULL
    val <- rep(NA, 4)
    up <- coords + c(1,0)
    if(up[1] <= nrow(maze)){
        out.coords <- rbind(out.coords, up)
        val[3] <- maze[up[1],up[2]]
    }
    dn <- coords + c(-1,0)
    if(dn[1] > 0){
        out.coords <- rbind(out.coords, dn)        
        val[1] <- maze[dn[1],dn[2]]
    }
    lf <- coords + c(0,-1)
    if(lf[2] > 0){
        out.coords <- rbind(out.coords, lf)
        val[2] <- maze[lf[1],lf[2]]
    }
    rt <- coords + c(0,1)
    if(rt[2] <= ncol(maze)){
        out.coords <- rbind(out.coords, rt)
        val[4] <- maze[rt[1],rt[2]]
    }
    if(return.coords){
        return(out.coords)
    }
    return(val)
}
diag_adj_vals <- function(coords, maze){
    val <- rep(NA, 4)
    ul <- coords + c(1,-1)
    if(ul[1] <= nrow(maze) && ul[2] > 0){
        val[1] <- maze[ul[1],ul[2]]
    }
    ur <- coords + c(1,1)
    if(ur[1] <= nrow(maze) && ur[2] <= ncol(maze)){
        val[2] <- maze[ur[1],ur[2]]
    }
    dl <- coords + c(-1,-1)
    if(dl[1] > 0 && dl[2] > 0){
        val[3] <- maze[dl[1],dl[2]]
    }
    dr <- coords + c(-1,1)
    if(dr[1] > 0 && dr[2] <= ncol(maze)){
        val[4] <- maze[dr[1],dr[2]]
    }
    return(val)
}
previous <- function(coords, maze){
    dir <- maze[coords[1],coords[2]]
    if(dir == 0){
        return(c(NA, NA))
    }
    # reverse the move that was taken to get here
    prev <- switch(dir,
                   '1' = coords + c(1,0),
                   '2' = coords + c(0,1),
                   '3' = coords + c(-1,0),
                   '4' = coords + c(0,-1))
    return(prev)
}
fill_maze <- function(maze, start = NULL){
    while(any(maze == -1)){
        if(is.null(start)){
            # pick a not-exactly-random start
            s1 <- as.numeric(sample(as.character( # more coding around "sample"
                seq_len(nrow(maze))[rowSums(maze==-1) > 0]), 1))
            s2 <- as.numeric(sample(as.character(which(maze[s1,]==-1)), 1))
            start <- c(s1,s2)
        }
        maze[start[1],start[2]] <- 0
        last <- curr <- start
        adj <- adjacent(last, maze)
        poss <- which(adj == -1)
        while(! (length(poss) == 0 & all(curr == start))){
            # if no valid options, back up one step and try again
            if(length(poss) == 0){
                curr <- previous(last, maze)
            }else{
                # pick next step
                dir <- poss[sample(length(poss), 1)] # coding around sample's "convenience" feature
                curr <- switch(dir,
                               '1' = last + c(-1,0), # technically, the names are 
                               '2' = last + c(0,-1), # unnecessary. It's picking
                               '3' = last + c(1,0),  # the correct case based on 
                               '4' = last + c(0,1))  # position, not name
                maze[curr[1],curr[2]] <- dir
            }
            last <- curr
            # identify possible next steps from neighbors of 'last'
            adj <- adjacent(last, maze)
            poss <- which(adj == -1)
        }
        start <- NULL
    }
    return(maze)
}


# convert to thick-walled

toThick <- function(m){
    m2 <- matrix(NA, 2*nrow(m)+1, 2*ncol(m)+1)
    m2[,1] <- m2[,ncol(m2)] <- -5
    m2[1,] <- m2[nrow(m2),] <- -5
    for(i in 1:nrow(m)){
        for(j in 1:ncol(m)){
            dir <- m[i,j]
            m2[2*i, 2*j] <- dir
            if(dir != 0){
                # reverse the move that was taken to get here
                prev <- switch(dir,
                               '1' = 2*c(i,j) + c(1,0),
                               '2' = 2*c(i,j) + c(0,1),
                               '3' = 2*c(i,j) + c(-1,0),
                               '4' = 2*c(i,j) + c(0,-1))
                m2[prev[1], prev[2]] <- dir
            }
        }
    }
    m2[is.na(m2)] <- -5
    m2[m2 >= 0] <- 1
    return(m2)
}


# maze manipulation
expand <- function(m){
    m2 <- matrix(NA, nrow = 2*nrow(m), ncol = 2*ncol(m))
    for(i in 1:ncol(m)){
        m2[,2*i-1] <- m2[,2*i] <- rep(m[,i], each = 2)
    }
    return(m2)
}
condense <- function(m, fun = median){
    odd.col <- (ncol(m) %% 2) == 1
    odd.row <- (nrow(m) %% 2) == 1
    m2 <- matrix(NA, nrow = ceiling(nrow(m)/2), ncol = ceiling(ncol(m)/2))
    for(i in 1:(nrow(m2))){
        for(j in 1:(ncol(m2))){
            i.2 <- (2*i-1):(2*i)
            j.2 <- (2*j-1):(2*j)
            if(i == nrow(m2)){
                i.2 <- (nrow(m)-1):nrow(m)
            }
            if(j == ncol(m2)){
                j.2 <- (ncol(m)-1):ncol(m)
            }
            m2[i,j] <- fun(m[i.2 , j.2])
        }
    }
    return(m2)
}
seep <- function(m, what = 1){
    m2 <- m
    for(i in 2:nrow(m)){
        m2[i, ][m[i-1, ]==what] <- what
    }
    for(i in 1:(nrow(m)-1)){
        m2[i, ][m[i+1, ]==what] <- what
    }
    for(j in 2:ncol(m)){
        m2[,j][m[,j-1]==what] <- what
    }
    for(j in 1:(ncol(m)-1)){
        m2[,j][m[,j+1]==what] <- what
    }
    return(m2)
}




# paths
# not built for matrix mazes (yet)
solvemaze <- function(maze, start=NULL, end=NULL){
    if(is.null(start)){
        start <- c(NA,NA)
        # left, bottom
        start[2] <- which.max(apply(maze, 2, function(x) {any(x != -5)}))
        start[1] <- which.max(maze[,start[2]] != -5)
    }
    if(is.null(end)){
        end <- c(NA,NA)
        # right, top
        end[2] <- max(seq_len(ncol(maze))[apply(maze, 2, 
                                                function(x) {any(x != -5)})] )
        end[1] <- max(seq_len(nrow(maze))[maze[,end[2]] != -5])
    }
    # p1: start -> root
    p1 <- start
    parent <- previous(start, maze)
    while(!anyNA(parent)){
        p1 <- rbind(p1, parent)
        parent <- previous(parent, maze)
    }
    p1.text <- paste(p1[,1], p1[,2])
    end.text <- paste(end[1], end[2])
    if(end.text %in% p1.text){
        return(p1[1:which.max(p1.text==end.text), 2:1])
    }
    # p2: end -> root
    p2 <- end
    parent <- previous(end, maze)
    while(!anyNA(parent)){
        p2 <- rbind(p2, parent)
        parent <- previous(parent, maze)
    }
    p2.text <- paste(p2[,1], p2[,2])
    start.text <- paste(start[1], start[2])
    if(start.text %in% p2.text){
        return(p2[which.max(p2.text==start.text):1, 2:1])
    }
    while(p1.text[length(p1.text)] == p2.text[length(p2.text)]){
        last <- p1.text[length(p1.text)]
        p1.text <- p1.text[-length(p1.text)]
        p2.text <- p2.text[-length(p2.text)]
    }
    path.text <- c(p1.text, last, rev(p2.text))
    path <- t(vapply(path.text, function(x){
        as.numeric(unlist(strsplit(x, split = ' ')))
    }, c(1,1)))
    rownames(path) <- NULL
    return(path[,c(2,1)])
}
