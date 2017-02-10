## UL webscrape

# Another Approach: using the web scrap to find the keyword of the file(instead of relying on the filename), note: not all the url of files are valid
# ------------------------ Rselenium : Package for animation of the web browser ----------------------------------------- #

require(RSelenium)
# checkForServer(update = TRUE)
startServer()
mybrowser <- remoteDriver(browserName = "chrome")
mybrowser$open()

url = 'https://ul.webdamdb.com/cloud/#asset/23394512' # sample valid link to be redirected to login interface
mybrowser$navigate(url)

# Automatically navigate to the user-login interface,'****' should be replaced by valid user name to login

username <- mybrowser$findElement(using = 'css selector', "#username")
username$sendKeysToElement(list("*****"))
password <- mybrowser$findElement(using = 'css selector', '#password')
password$sendKeysToElement(list("*****"))
loginbutton <- mybrowser$findElement(using = 'css selector', "#loginSbtButton")
loginbutton$clickElement()

mybrowser$setTimeout(type = "page load", milliseconds = 20000)
mybrowser$setImplicitWaitTimeout(milliseconds = 10000)

# refresh the url once again

url = 'https://ul.webdamdb.com/cloud/#asset/23394512'

mybrowser$navigate(url)
keyword <- mybrowser$findElement(using = 'css selector', "#keywordTags")
key =keyword$getElementText()[[1]]
typeof(key)
# valid result are one string, words are seperated by /n

# sample invalid links give '' as result when try to find the keyword, sometimes give error
url = 'https://ul.webdamdb.com/cloud/#asset/23434246'
mybrowser$navigate(url)
keyword <- mybrowser$findElement(using = 'css selector', "#keywordTags")
keyword$getElementText()[[1]]


###################### web scrape the keywords from all the download URL #######################

URLs = unique(download$URL)
invalid_url = grep('http',URLs,value = T,invert = T)
URLs = URLs[URLs!= invalid_url]
KEYWORDs = rep('',length(URLs))
URL_KEYWORD = data.frame(URLs,KEYWORDs)
URL_KEYWORD$KEYWORDs = as.character(URL_KEYWORD$KEYWORDs)
URL_KEYWORD$URLs = as.character(URL_KEYWORD$URLs)

typeof(URL_KEYWORD$KEYWORDs)
typeof(URL_KEYWORD$URLs)

# record r output
#out <- file('~/Brand Hub Data 2/Explore 2/output1.txt', open = "wt")
# sink(out)

# initialize status
startServer()
mybrowser <- remoteDriver(browserName = "chrome")
mybrowser$open()


for(i in 1:dim(URL_KEYWORD)[1]){
  tryCatch( {
    if(i %% 50 == 1 ){
      mybrowser$close()
      mybrowser <- remoteDriver(browserName = "chrome")
      mybrowser$open()
      Sys.sleep(7)
      mybrowser$setTimeout(type = "page load", milliseconds = 20000)
      mybrowser$setImplicitWaitTimeout(milliseconds = 10000)
      u = 'https://ul.webdamdb.com/cloud/#asset/23394512' # sample valid link to be redirected to login interface
      mybrowser$navigate(u)
      Sys.sleep(7)
      
      # Automatically navigate to the user-login interface
      username <- mybrowser$findElement(using = 'css selector', "#username")
      username$sendKeysToElement(list("*****"))
      password <- mybrowser$findElement(using = 'css selector', '#password')
      password$sendKeysToElement(list("*****"))
      loginbutton <- mybrowser$findElement(using = 'css selector', "#loginSbtButton")
      loginbutton$clickElement()
      Sys.sleep(7)
      print("LOGIN SUCCESS")
      
    }
    
    url = URL_KEYWORD[i,'URLs']
    print(url)
    mybrowser$navigate(url)
    Sys.sleep(3)
    keyword <- mybrowser$findElement(using = 'css selector', "#keywordTags")
    key = keyword$getElementText()[[1]]
    URL_KEYWORD[i,'KEYWORDs'] = key
    print(key)
    
  },error = function(e){
    print( paste0('ERROR DETECTED ', head(e))) } )
}

# close the browser  
mybrowser$close()
mybrowser$closeServer()

# sink(); sink();
View(URL_KEYWORD)

# URL_KEYWORD
empty = which(URL_KEYWORD$KEYWORDs == '')
nonempty = which(URL_KEYWORD$KEYWORDs$KEYWORDs)
length(empty);length(nonempty)
# SUMMARY: The combined table has 4704 URLs, among them 2287 are unique URLs.
# 850 of which still has valid links and has tagged with keywords. 1437 of them are either invalid or no keyword

# subsitute '\n' as ' '
URL_KEYWORD$KEYWORDs = gsub('\n',' ',URL_KEYWORD$KEYWORDs)

## pair up keyword with each observation in download file

for (i in 1:dim(download)[1]){
  idx = which(URL_KEYWORD$URLs == download[i,'URL'])
  print(idx)
  if(length(idx)!= 0){
    download[i,'Keywords'] = URL_KEYWORD[idx,'KEYWORDs']
  }
}


############################ Web scape UL EMPLOYEE TITLE ##########################################

#ProfJobTitleField
#BaseOfficeLocationField

require(RSelenium)

#system("java -version")
# make sure the system enviroment is Java 7
startServer()
mybrowser <- remoteDriver(browserName = "chrome")
mybrowser$open()
mybrowser$setTimeout(type = "page load", milliseconds = 20000)
mybrowser$setImplicitWaitTimeout(milliseconds = 10000)

url = 'http://intranet.ul.com/ULSearch/Pages/peopleresults.aspx?k=matthew.dragon%40ul.com'  # sample valid link to be redirected to login interface
mybrowser$navigate(url)
Sys.sleep(2)

tryCatch(
  {
    titlefield <- mybrowser$findElement(using = 'css selector', "#JobTitleField")
    title = titlefield$getElementText()[[1]]
  }, error = function(e){
    titlefield <- mybrowser$findElement(using = 'css selector', "#ProfJobTitleField")
    title = titlefield$getElementText()[[1]]
    print(title)
  }
  print(title)
)
officeloc <- mybrowser$findElement(using = 'css selector', '#BaseOfficeLocationField')
office = officeloc$getElementText()[[1]]

# Extract the unique UL employee, and Prepare for the URL
UL_email = LD.visitor[which(LD.visitor$Type=='ul'),'email']
UL= gsub('@','%40', UL_email)
UL_url = paste0("http://intranet.ul.com/ULSearch/Pages/peopleresults.aspx?k=",UL)
len = length(UL_url)
out = matrix('',nrow = len, ncol = 3)
out[,1] = as.character(UL_email)
View(out)

title_output <- file('~/Brand Hub Data 2/Explore 2/title_output.txt', open = "wt")
sink(title_output)

for(i in 1:length(UL)){
  tryCatch(
    {
      url = UL_url[i]
      print(out[i,1])
      mybrowser$navigate(url)
      Sys.sleep(2)
      
      tryCatch(
        {
          titlefield <- mybrowser$findElement(using = 'css selector', "#JobTitleField")
          out[i,2] = titlefield$getElementText()[[1]]
        }, error = function(e){
          titlefield <- mybrowser$findElement(using = 'css selector', "#ProfJobTitleField")
          out[i,2] = titlefield$getElementText()[[1]]
          print(out[i,2])
        }
      )
      print(out[i,2])
      
      officeloc <- mybrowser$findElement(using = 'css selector', '#BaseOfficeLocationField')
      out[i,3] = officeloc$getElementText()[[1]]
      print(out[i,3])
      print(' ')
      
    },error = function(e){
      print(paste("ERROR!", e))
    }
    
  )
}
colnames(out) = c("Email",'Title','Location')
View(out)
#write.table(out,"~/Brand Hub Data 2/Explore 2/Visualization/UL Title.csv", row.names =F, sep =',', quote= F)


UL.Title <- read.csv("~/Brand Hub Data 2/Explore 2/Visualization/UL Title.csv", stringsAsFactors =F)
missed$Title = as.character(missed$Title)
View(UL.Title)


