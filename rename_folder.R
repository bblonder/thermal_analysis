library(lubridate)

parse_datestring <- function(str)
{
	str <- as.character(str)
	dt <- as.POSIXlt(strptime(str,"%y%m%d-%H%M%S",tz="GMT"))
	
	return(dt)
}

process_folder <- function(dir_in, dir_out, year2, month2, day2, hour2, minute2, sec2)
{
	dirname = tail(strsplit(dir_in,'/')[[1]],1)
	id_numeric = tail(strsplit(dirname, '_')[[1]],1)
	
	id_new = sprintf("%02d%02d%02d_%02d%02d%02d", year2, month2, day2, hour2, minute2, sec2)
	
	#print(dirname)
	#print(id_numeric)
	#print(id_new)
	files = dir(path=dir_in, full.names=F)
	
	files_renamed = gsub(id_numeric, id_new, files)
	#print(cbind(files, files_renamed))

	
	# make output directory
	ifelse(!dir.exists(dir_out), dir.create(dir_out), FALSE)
	
	# start moving files
	for (i in 1:length(files))
	{
		fcs = file.copy(from=file.path(dir_in, files[i]),to=file.path(dir_out,files_renamed[i]))
		print(paste(files[i],files_renamed[i],fcs))
		try(stopifnot(fcs==TRUE))
	}
	cat('\n')
	
	
	file_stats_all = dir(path=dir_out, full.names=F, pattern="*-stats.csv")
		
	file_stats_first = dir(path=dir_in, full.names=F, pattern="*000000-000000-stats.csv") # needs to be in dir
	print(file_stats_first)
	stopifnot(length(file_stats_first)==1)
	#print(file_stats_first)
	
	stats_first = read.csv(file.path(dir_in, file_stats_first))
	#print(stats_first)
	
	# get the starting time in this series
	date_start <- parse_datestring(stats_first$Date[1])
	date_start_new <- parse_datestring(gsub("_","-",id_new))

	print(date_start_new)	
	#print(date_start)
	
	# start moving files
	for (i in 1:length(file_stats_all))
	{
		try(
		{
			stats_this = read.csv(file.path(dir_out, file_stats_all[i]))
			
			#print(paste("orig",stats_this$Date))
			date_this = parse_datestring(stats_this$Date)
			#print(paste("parsed", date_this))
			datediff = as.duration(date_this - date_start)
			#print(paste("difference",datediff))
			#print(paste("orig", date_start_new))
			date_new = date_start_new + datediff
			#print(paste("fixed",date_new))
			
			stats_this$Date <- strftime(date_new,format="%y%m%d-%H%M%S")
			
			print(cbind(file_stats_all[i],stats_this[,c("Date","gps_utc")]))
			
			write.csv(stats_this, file=file.path(dir_out, file_stats_all[i]),row.names=F)
		})
	}
	cat('\n')
}
