#evrythg needs to be in same directory. EVERYTHING
r<-read.table('/home/guy/input', head=F)  
  #
write.table(r, file = '/home/guy/splatche3/template/tempor.txt')

print(r)

file.copy('/home/guy/splatche3/template/template.txt',  #template
          '/home/guy/splatche3/template/template_input.txt', #the actual input
          overwrite = T #files must be overwritten to replace for each
          )
  #creates new file, and writes it to a new file w/out AncSize for each sim

a = r[1,]#floor(runif(1, min = 1, max = 500)) #creates shifting prior for AncSize

write(sprintf("RiverCarCapChangeFactor=%f", a),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
      )
    #appends the sprintf txt to the bottom of the file 

b = r[2,]#runif(1, min = 0, max = 0.5) #creates shifting prior for MigraRate, P1
  #set between 0.1,0.1 when you dont want shifting.

write(sprintf("MigrationRate=%f", b),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
     )

c = r[3,]#runif(1, min = 0, max = 0.5) #creates shifting prior for MigraRate, P2

write(sprintf("MigrationRate_P2=%f", c),
      "/home/guy/splatche3/template/template_input.txt",
       append = T
      )

d = r[4,]#runif(1, min = 0, max = 0.7) #creates shifting prior for adm P1 to P2

write(sprintf("MigrRate_P1_to_P2=%f", d),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
       )

e = r[5,]#runif(1, min = 0, max = 0.7) #creates shifting prior for adm P2 to P1

write(sprintf("MigrRate_P2_to_P1=%f", e),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
)

f = r[6,]#runif(1, min = 0, max = 0.7) #creates shifting growth P1 ###

write(sprintf("GrowthRate=%f", f),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
)

g = r[7,]#runif(1, min = 0, max = 0.7) #creates shifting growth P2

write(sprintf("GrowthRate_P2=%f", g),
      "/home/guy/splatche3/template/template_input.txt",
      append = T
)