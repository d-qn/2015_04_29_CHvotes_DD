library("swiTheme")
library("swiRcharts")
library("dplyr")

############################################################################################
###		SETTINGS
############################################################################################

subsetLang <- NULL

# download the raw file without footer!!!
votefile <- "data/allCH_ballots - VOTES_allCH_2015-06-14.csv"
votes.read <- read.csv(votefile, check.names = F, stringsAsFactors = F)

trad <- read.csv("data/allCHVotes_byYes.tsv", sep ="\t", row.names = 1, stringsAsFactors = F)

votes.read <- read.csv(votefile, check.names = F, stringsAsFactors = F)


# PLOT SETTINGS
plot.height <- 450
outputDir <- "graphics_yes"

if(!file.exists(outputDir)) {
	dir.create(outputDir)
}

############################################################################################
###		load ballot data
############################################################################################

votes.read$type <- as.factor(votes.read$type)

## transform date to date
votes.read$date <- as.Date(votes.read$`Date of Votes`, format = "%d/%m/%Y")

votes.read$diffYesNo <- votes.read$`Yes Votes` - votes.read$`No Votes`


### hack to replace result unknown with yes!!
votes.read[which(votes.read$Result == ''), 'Result'] <- 'yes'

cols <- c('fre', 'date', 'type')
votesYes <- votes.read %>% filter(Result == "yes")
votesYes[which(rank(votesYes$diffYesNo) <= 2),cols]

votesNo <- votes.read %>% filter(Result == "no")
votesNo[which(rank(abs(votesNo$diffYesNo)) <= 2),cols]























## add bin %yes
breaks <- 0:95
votes.read$binYes <- as.numeric(as.character(cut(votes.read[,'Yes [%]'], breaks = breaks, labels = breaks[-length(breaks)])))

## add counter of ballot type per binYes
votes.read <- do.call(rbind, by(votes.read, list(votes.read$binYes, votes.read$type), function(ii) {
	cbind(ii, n = as.numeric(0:(nrow(ii)-1)))
}))


##### DEBUGGING CASE ~~~~~~~~~~~~
votetype <- levels(votes.read$type)[2]
lang <- colnames(trad)[1]

## SUBSET DATA if subsetLang is defined
if(is.null(subsetLang) || length(subsetLang) > 0) {
	trad <- select(trad, one_of(subsetLang))
}

for(votetype in levels(votes.read$type)) {

	for(lang in colnames(trad)) {

		# Define output files
		typeShort <- gsub(" ", "", votetype)
		tmpOuputfile <- paste0(outputDir, "/", typeShort, ".html")
		output.html <- paste0(typeShort, "_", lang, "_byYes_heatmap.html")

		# Define which vote colname to use
		col.subset <- c(lang, 'binYes', 'n', 'Yes [%]', 'Result', 'date', 'Turnout', 'Yes Votes', 'No Votes')

		# subset ballot data for the ballot type and the languages
		data <- votes.read %>% filter(type == votetype) %>% select(one_of(col.subset))
		#
		title.bak <- data[,lang]

		# rename data for highcharts
		colnames(data)[1:5] <- c('name', 'x', 'y', 'value', 'result')

		# add HTML break for name longer than 50 characters
		data$name <- gsub('(.{1,50})(\\s|$)', '\\1\\<br\\>', data$name)

		# Perform vote type specific stuff
		# heatmap colors
		color0.5 <- '#ADC2C2'
		color1 <- '#0F1F1F'
		subtitle.x <- 5
		subtitle.align <- "left"
		resetZoomButton.align <- "right"
		if(typeShort == 'facultativeReferendum') {
			color0.5 <- '#C2C2D1'
			color1 <- '#1A1A33'
		}
		if(typeShort == 'mandatoryReferendum') {
			color0.5 <- '#C2C2D1'
			color1 <- '#1A1A33'
			subtitle.align <- "right"
			subtitle.x <- -5
			resetZoomButton.align <- "left"
		}

		## Create the new name as an HTML table (http://rcharts.io/viewer/?5735146)

		if(lang == "ara") {
			data$name <- paste0(
				'<table cellpadding="1" style="line-height:1.4">',
			        '<tr><td align="right"><div style="font-size:0.95em">', data$date, '</td></div>',
						'<td></td><td></td></tr>',
			       '<tr><td colspan="3" align="right"><b><div style="font-size:1.2em">', data$name, '</b></div><hr></td></tr>',
			       '<tr><td align="right">', trad["tp.yes",lang], ': <b>', round(data$value, 1), '%</b>', '</td><td></td>',
				   		'<td align="left">', trad["tp.turnout",lang],  " : ",
						ifelse(round(data$Turnout, 1) == 0, " ", paste0(round(data$Turnout, 1), "%")), '</td></tr>',
					'<tr><td colspan="3" align="center"><div style="color:#999999">',
						ifelse(data$result == "no", trad["tp.refused",lang], trad["tp.accepted",lang]), '</td></tr>',
				'</table></div>')
		} else if( lang %in% c('jpn', 'chi')) {
			data$name <- paste0(
				'<table cellpadding="1" style="line-height:1.4">',
			        '<tr><td><div style="font-size:0.9em">', data$date, '</td></div>',
						'<td></td><td></td></tr>',
			       '<tr><td colspan="3"><div style="font-size:1.1em">', data$name, '</div><hr></td></tr>',
			       '<tr><td align="left">', trad["tp.yes",lang], ': <b>', round(data$value, 1), '%</b>', '</td><td></td>',
				   		'<td style="text-align:right">', trad["tp.turnout",lang],  " : ",
						ifelse(round(data$Turnout, 1) == 0, " ", paste0(round(data$Turnout, 1), "%")), '</td></tr>',
					'<tr><td colspan="3" align="center"><div style="color:#999999">',
						ifelse(data$result == "no", trad["tp.refused",lang], trad["tp.accepted",lang]), '</td></tr>',
				'</table></div>')
		} else {
			data$name <- paste0(
				'<table cellpadding="1" style="line-height:1.4">',
			        '<tr><td><div style="font-size:0.9em">', data$date, '</td></div>',
						'<td></td><td></td></tr>',
			       '<tr><td colspan="3"><i><div style="font-size:1.1em">', data$name, '</i></div><hr></td></tr>',
			       '<tr><td align="left">', trad["tp.percyes",lang], ': <b>', round(data$value, 2), '%</b>', '</td><td></td>',
				   		'<td style="text-align:right">', trad["tp.turnout",lang],  " : ",
						ifelse(round(data$Turnout, 1) == 0, " ", paste0(round(data$Turnout, 1), "%")), '</td></tr>',
 			       '<tr><td align="left">', trad["tp.yes",lang], ': ', data$`Yes Votes`, '</td><td></td>',
 				   		'<td style="text-align:right">', trad["tp.no",lang],  " : ",  data$`No Votes`, '</td></tr>',
					'<tr><td colspan="3" align="center">', trad["tp.yesminusno",lang], " : ", data$diffYesNo, '</td></tr>',
					'<tr><td colspan="3" align="center"><div style="color:#999999">',
						ifelse(data$result == "no", trad["tp.refused",lang], trad["tp.accepted",lang]), '</td></tr>',
				'</table></div>')
		}

		## Heatmap column chart
		a <- Highcharts$new()
		# use type='heatmap' for heat maps
		a$chart(zoomType = "x", type = 'heatmap', height = plot.height, plotBackgroundColor = "#f7f5ed", spacing = 5,
			resetZoomButton = list(position = list( align = resetZoomButton.align )))
		#a$series(hSeries2(data, "result"))
		a$series(lapply(hSeries2(data, "result"), function(ll) c(ll, list(borderWidth= 1))))
		a$plotOptions(series = list(borderColor = "#f7f5ed"))


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
		         verticalAlign='top',
				 symbolWidth = 100,
		         symbolHeight=5
		)

		a$xAxis(min = 0, max = 95, ceiling = 95, maxPadding = 0, tickAmount = 0,title = list(text = trad["tp.percyes",lang]))
		a$yAxis(min = min(data$y), max = max(data$y),
			maxPadding = 0, lineWidth = 0, minorGridLineWidth = 0, lineColor = 'transparent', title = list(text = ""),
			labels = list(enabled = F), minorTickLength = 0, tickLength =  0, gridLineWidth =  0, minorGridLineWidth = 0)

		a$tooltip(formatter = "#! function() { return this.point.name; } !#", useHTML = T,
			borderWidth = 2, backgroundColor = 'rgba(255,255,255,0.8)', style = list(padding = 3))

		addhtmlbreak <- function(text) {
			gsub('(.{1,35})(\\s|$)', '\\1\\<br\\>', text)
		}
		a$addAssets(c("https://code.highcharts.com/modules/heatmap.js"))
		a$save(destfile = tmpOuputfile)

		yRange <- paste(range(as.numeric(substr(data$date,1,4))), collapse = "-")

		h2title <- paste0(trad[eval(paste("title", typeShort, sep = ".")),lang], " (", yRange, ")")
		source <- paste0(trad["source1",lang], '<a href="', trad["sourceLink",lang], '" target = "_blank"> ', trad["source2",lang], '</a>')
		hChart2responsiveHTML(tmpOuputfile, output.html = output.html, output = outputDir, h2 = h2title,
			descr = "", source = source, h3 = "", author = ' <a href = "http://www.swissinfo.ch">swissinfo.ch</a>')

		browseURL(file.path(outputDir, output.html))

	} # end loop language

} # end loop votetype






