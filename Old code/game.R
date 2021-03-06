game <- function(N,T) {
	death_prob  <- rep(.5,2*N)
	hist0       <- matrix(0,N,4)
	hist1 	<- matrix(1,N,4)
	strat0	<- matrix(0,N,16)
	strat1	<- matrix(1,N,16)
	periods	<- rep(0,2*N)
	game_mat	<- cbind(death_prob,rbind(hist0,hist1),rbind(strat0,strat1),periods)
	
	powers_vec <- c(32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1)
	
	stats       <- matrix(0,T/4,2)

	mutate_prob <- .00125
	
	for (t in 1:T) {
		#mutate_prob <- 1/(100*(t^(1/3)))
		game_mat  <- game_mat[sample(2*N),]
		game_mat <- play(game_mat)
		
		if (t/4 == floor(t/4)) {
			stats[t/4,1] <- t
			stats[t/4,2] <- sum(game_mat[,2:5])/(8*N)
			# print(sum(game_mat[,2])/(2*N))
			# print(table(colSums(powers_vec*t(game_mat[,6:21]))))	
		}
		
		if (t/100 == floor(t/100)) {
			print(table(colSums(powers_vec*t(game_mat[,6:21]))))
		}
		
		probs <- runif(2*N)
		
		is_alive  <- probs > game_mat[,1]
		is_mutate <- probs > 1 - mutate_prob
		
		num_alive  <- sum(is_alive)
		num_mutate <- sum(is_mutate)

		if (num_mutate > 0) {
			mutations <- mutate(matrix(game_mat[is_mutate,],ncol=22))
			game_mat[1:num_alive,] <- game_mat[is_alive,]
			game_mat[(num_alive+1):(num_alive+num_mutate),] <- mutations
		}
		else {
			game_mat[1:num_alive,] <- game_mat[is_alive,]
		}

		#game_mat <- rbind(game_mat[is_alive,],mutations)

		#game_mat <- rbind(game_mat,mutate(game_mat[is_mutate,]))

		births <- sample(1:num_alive, 2*N - num_alive - num_mutate, replace=TRUE)
		game_mat[(num_alive+num_mutate+1):(2*N),] <- game_mat[births,]
		
		#game_mat <- rbind(game_mat,game_mat[births,])
		
		# stats[t,1] <- t
		# stats[t,2] <- sum(game_mat[,2])/(2*N)
		
		# if (t/100 == floor(t/100)) {
			# print(t)
			# print(table(game_mat[,1]))
		# }
	}
	
	#print(2*N-num_alive)
	print(game_mat)
	
	print(stats)
}