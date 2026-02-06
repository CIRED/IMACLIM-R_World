# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

library(cairoDevice)

dgH <- filter(dg , product!="ICT" & product!="NonICT" & product!="GFCF"); # à remettre en ligne sur barplot

#mapvalues(dgH$country,from="USA-NAICS",to="USA")
countries = unique( dgH$country )
vars      = unique( dgH$var     )

if (FALSE)
{
    for ( countryHere  in countries )
    {

        dir.create(paste0("plottedData/", countryHere ))

        secmat   = filter(dgH, country == countryHere , var=="Iq")
        products = unique(secmat$product)
        for (productHere in products)
        {
            submat = filter(secmat, product == productHere )
            if (!all(is.na(submat$value)))
            {
                p <- ggplot(submat, aes( x=year, y=value, colour=industry)) + geom_line()
                if (length(unique(submat$unit)) == 1)
                {
                    p + ggtitle(paste0(productHere,"\n",unique(submat$unit))) + theme(plot.title = element_text(lineheight=.8, face="bold"))
                } else {
                    p + ggtitle(productHere) + theme(plot.title = element_text(lineheight=.8, face="bold"))
                }
                ggsave(filename=paste(productHere,"pdf",sep="."),path=paste0("plottedData/", countryHere ),device=cairo_pdf)
            }
        }
    }

    folder <- paste0(getwd(),"/plottedData/")
    cat("Results will be located in",folder,"\n\n")

    dir.create(folder)

    for (varHere in vars) 
    {
        for ( productHere  in levels(dgH$product) )
        {
            p <- ggplot( filter( dgH , product ==productHere , industry == "TOT" , var==varHere ) , aes( x=year, y=value, colour=country)) + geom_line()
            titleHere <- paste0( varHere , "-" , productHere );
            print(titleHere)
            p + ggtitle( titleHere ) + theme(plot.title = element_text(lineheight=.8, face="bold"))
            ggsave(filename=paste( titleHere ,"pdf",sep="."),path=folder,device=cairo_pdf)
        }
    }


    for (varHere in vars) 
    {
        for ( countryHere  in countries )
        {
            dataHere <- filter( dgH , country==countryHere , industry == "TOT" , var==varHere )
            if (all(is.na(dataHere$value)))
            {
                p <- ggplot( )
            } else {
            {
                p <- ggplot( dataHere , aes( x=year, y=value, colour=product)) + geom_line()
            }
            titleHere <- paste0( varHere , "-" , countryHere );
            print(titleHere)
            p + ggtitle( titleHere ) + theme(plot.title = element_text(lineheight=.8, face="bold"))
            ggsave(filename=paste( titleHere ,"pdf",sep="."),path= folder ,device=cairo_pdf)
            }
        }
    }
}

