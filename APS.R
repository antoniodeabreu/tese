install.packages("hash", lib="/home/antonio.batista/Rpacks") 

require(hash, "/home/antonio.batista/Rpacks")
require(jsonlite, "/home/antonio.batista/Rpacks")


#find the position of the nth occurrence of str2 in str1(same order of parameters as Oracle SQL INSTR), returns 0 if not found
instr <- function(str1,str2,startpos=1,n=1){
  aa=unlist(strsplit(substring(str1,startpos),str2))
  if(length(aa) < n+1 ) return(0);
  return(sum(nchar(aa[1:n])) + startpos+(n-1)*nchar(str2) )
}



p2p<-hash()

p <- "/home/antonio.batista/antonio/APS/aps-dataset-citations-2018.csv"   
conn <- file(p,open="r")  
lines <- readLines(conn)
close(conn)

for (i in 2:length(lines)){ 
  id<-substr(lines[i], instr(lines[i],",")+1 ,  nchar(lines[i]))
  .set(p2p,id,list())
}


for (i in 2:length(lines)){ 
  id_citing<-substr(lines[i], 0 , instr(lines[i],",")-1 )
  id_cited<-substr(lines[i], instr(lines[i],",")+1 ,  nchar(lines[i]))
	.set(p2p,id_cited,c(p2p[[id_cited]],list(id_citing)))
}






year<-hash()
p2v<-hash()

for(p in keys(p2p)){
  .set(year,p,0000)
}

p<-"/home/antonio.batista/antonio/APS/aps"
temp = list.files(p,pattern="*.json")

for (i in temp){
  i2<-paste(p, sep = "/",  i) 
  data <- fromJSON(i2)
  .set(year,data$id,data$rights$copyrightYear)  
  .set(p2v,data$id,data$journal$id)
}

#mover todos os files em subdiretótios para um só diretório
find /home/antonio.batista/antonio/APS/aps-dataset-metadata-2018 -maxdepth 5 -type f -print0 | xargs -0 mv -t /home/antonio.batista/antonio/APS/aps



a2p<-hash()


p <- "/home/antonio.batista/antonio/APS/APS_author2DOI.dat"   
conn <- file(p,open="r")  
lines <- readLines(conn)
close(conn)


for (i in 2:length(lines)){ 
  v1<-substr(lines[i],instr(lines[i],",")+1, nchar(lines[i]))
  name<-substr(v1, 1 , instr(v1,",")-1 )
  .set(a2p,name,list())
}




for (i in 2:length(lines)){ 

  v1<-substr(lines[i],instr(lines[i],",")+1, nchar(lines[i]))


  name<-substr(v1, 1 , instr(v1,",")-1 )

  papers<-substr(v1, instr(v1,"," )+1, nchar(v1))


  while(instr(papers,"\t" )!=0){
    .set(a2p,name, c(a2p[[name]], list(substr(papers, 1, instr(papers,"\t" )-1))))
    papers<-substr(papers, instr(papers,"\t" )+1, nchar(papers))

  }
}



p2a<-hash()

for (a in keys(a2p)){
  for( p in a2p[[a]]){
    .set(p2a, p, list())
  }
}

for (a in keys(a2p)){
  for( p in a2p[[a]]){
    .set(p2a, p, c(p2a[[p]], list(a)))
  }
}

