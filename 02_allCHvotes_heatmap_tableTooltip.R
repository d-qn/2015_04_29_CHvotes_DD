library("swiTheme")
library("swiRcharts")
library("dplyr")

############################################################################################
###		SETTINGS
############################################################################################

# download the raw file without footer!!!
votefile <- "data/allCH_ballots - VOTES_allCH_2015-05-13.csv"

# PLOT SETTINGS
plot.height <- 400
outputDir <- "graphics"

if(!file.exists(outputDir)) {
	dir.create(outputDir)
}

############################################################################################
###		load ballot data
############################################################################################

votes.read <- read.csv(votefile, check.names = F, stringsAsFactors = F)

votes.read$type <- as.factor(votes.read$type)

## transform date to date
votes.read$date <- as.Date(votes.read$`Date of Votes`, format = "%d/%m/%Y")

## add year
votes.read$year <- as.numeric(substr(votes.read$date,1, 4))

## add counter of ballot type per year
votes.read <- do.call(rbind, by(votes.read, list(votes.read$year, votes.read$type), function(ii) {
	cbind(ii, n = as.numeric(0:(nrow(ii)-1)))
}))

############################################################################################
###		Load microcopy translations
############################################################################################

trad <- read.csv("data/allCH_ballots - translations.tsv", sep ="\t", row.names = 1, stringsAsFactors = F)

## check microcopy translations are also present in the ballot data file
stopifnot(colnames(trad) %in% colnames(votes.read))

##### DEBUGGING CASE
votetype <- levels(votes.read$type)[2]
lang <- colnames(trad)[1]
#####

for(votetype in levels(votes$type)) {

	for(lang in colnames(trad)) {

		# Define output files
		typeShort <- gsub(" ", "", votetype)
		tmpOuputfile <- paste0(outputDir, "/", typeShort, ".html")
		output.html <- paste0(typeShort, "_", lang, "_heatmap.html")

		# Define which vote colname to use
		col.subset <- c(lang, 'year', 'n', 'Yes [%]', 'Result', 'date', 'Turnout' )

		# subset ballot data for the ballot type and the languages
		data <- votes.read %>% filter(type == votetype) %>% select(one_of(col.subset))

		title.bak <- data[,lang]

		# rename data for highcharts
		colnames(data)[1:5] <- c('name', 'x', 'y', 'value', 'result')

		# add HTML break for name longer than 50 characters
		data$name <- gsub('(.{1,50})(\\s|$)', '\\1\\<br\\>', data$name)

		# Perform vote type specific stuff
		# heatmap colors
		color0.5 <- '#ADC2C2'
		color1 <- '#336666'
		if(typeShort == 'faculativeReferendum') {
			color0.5 <- '#C2C2D1'
			color1 <- '#333366'
		}
		if(typeShort == 'mandatoryReferendum') {
			color0.5 <- '#D1D1C2'
			color1 <- '#666633'
		}

		## Create the new name as an HTML table (http://rcharts.io/viewer/?5735146)
		data$name <- paste0(
			'<table cellpadding="1" style="line-height:1.4">',
		        '<tr><td>', data$date, '</td>',
					'<td></td><td></td></tr>',
		       '<tr><td colspan="3"><i>', data$name, '</i><hr></td></tr>',
		       '<tr><td align="left">', 'Oui', ': <b>', round(data$value, 1), '%</b>', '</td><td></td>',
			   		'<td style="text-align:right">', 'Participation: ', round(data$Turnout, 1), '%</td></tr>',
				'<tr><td colspan="3" align="center">', data$result, '</td></tr>',
			'</table>')

		## Heatmap column chart

		a <- Highcharts$new()
		# use type='heatmap' for heat maps
		a$chart(zoomType = "xy", type = 'heatmap', height = plot.height, plotBackgroundColor = "#f7f5ed", spacing = 5)
		a$series(hSeries2(data, "result"))

		a$addParams(colorAxis =
		  list(min = 0, max = 100, stops = list(
			  list(0, '#ab3d3f'),
		      list(0.499, '#EED8D9'),
		      list(0.5, color0.5),
		      list(1, color1)
		  ))
		)

		a$legend(align='center',
		         layout='horizontal',
		         margin=-42,
				 width = 100,
		         verticalAlign='top',
		         symbolHeight=5
				 )

		a$xAxis(min = min(data$x), max = max(data$x), ceiling = max(data$x), maxPadding = 0, tickAmount = 2,title = list(text = ""))
		a$yAxis(min = min(data$y), max = max(data$y),
			maxPadding = 0, lineWidth = 0, minorGridLineWidth = 0, lineColor = 'transparent', title = list(text = ""),
			labels = list(enabled = FALSE), minorTickLength = 0, tickLength =  0, gridLineWidth =  0, minorGridLineWidth = 0)


		# formatter <- paste0("#! function() { return '<div class=\"tooltip\" style=\"color:#686868;font-size:0.8em\">",
		# 	trad[eval(paste("tp", "In", sep = ".")), lang], " <b>'+ this.point.x + ',</b> ", gsub("'", " ", trad[eval(paste("tp", typeShort, sep = ".")),lang]),
		# 	 ":<br><br><i>' + this.point.name + '</i><br>", trad[eval(paste("tp", "yield", sep = ".")),lang], " <b>' + this.point.value + '%</b> ",
		# 	  trad[eval(paste("tp", "ofyes", sep = ".")),lang], "</div>'; } !#")
		a$tooltip(formatter = "#! function() { return this.point.name; } !#", useHTML = T,
			borderWidth = 2, backgroundColor = 'rgba(255,255,255,0.8)', style = list(padding = 3))

		a$addAssets(c("https://code.highcharts.com/modules/heatmap.js"))
		a$save(destfile = tmpOuputfile)
		a

		yRange <- paste(range(data$x), collapse = "-")

		hChart2responsiveHTML(tmpOuputfile, output.html = output.html, output = outputDir, h2 = trad[eval(paste("title", typeShort, sep = ".")),lang],
		descr = paste0(trad[eval(paste("descr1", typeShort, sep = ".")),lang], " ", yRange, trad[eval(paste("descr2", typeShort, sep = ".")),lang]),
			source = trad["source",lang], h3 = "", author = 'Duc-Quang Nguyen | <a href = "http://www.swissinfo.ch">swissinfo.ch</a>')
		browseURL(file.path(outputDir, output.html))

	} # end loop language

} # end loop votetype


############################################################################################
###		KEYWORDS ANALYSIS
############################################################################################





