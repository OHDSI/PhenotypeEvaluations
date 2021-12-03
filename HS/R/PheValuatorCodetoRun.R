install.packages("drat")
drat::addRepo("OHDSI")
install.packages("PheValuator")


library(PheValuator)
outFolder <- "D:/StudyResults/2021/HSPaper/Phevaluator/OPTUMDOD" #replace with folder name

xSpecCohort <- 3887 #replace with generated xSpec cohort ID
xSensCohort <- 3888 #replace with generated xSens cohort ID
prevalenceCohort <- 3889 #replace with generated prevalence cohort ID
evaluationPopulationCohortId <- 3890 #replace with generated evaluation population cohort ID

# Create analysis settings ----------------------------------------------------------------------------------------
CovSettings <- createDefaultAcuteCovariateSettings(excludedCovariateConceptIds = c(), #add excluded concept ids if needed
                                                   addDescendantsToExclude = TRUE,
                                                   startDayWindow1 = 0, #change the feature windows if needed
                                                   endDayWindow1 = 30,
                                                   startDayWindow2 = 31,
                                                   endDayWindow2 = 365,
                                                   startDayWindow3 = 366,
                                                   endDayWindow3 = 9999)

CohortArgs <- createCreateEvaluationCohortArgs(xSpecCohortId = xSpecCohort,
                                               xSensCohortId = xSensCohort,
                                               prevalenceCohortId = prevalenceCohort,
                                               evaluationPopulationCohortId = evaluationPopulationCohortId,
                                               covariateSettings = CovSettings,
                                               lowerAgeLimit = 18,
                                               upperAgeLimit = 120,
                                               startDate = "20100101",
                                               endDate = "21000101")

#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = xSpecCohort)

analysis1 <- createPheValuatorAnalysis(analysisId = 1,
                                       description = "xSpec",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)

#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId = prevalenceCohort)

analysis2 <- createPheValuatorAnalysis(analysisId = 2,
                                       description = "Prevalence",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)

#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =2214) #change to first phenotype algorithm cohort ID to test

analysis3 <- createPheValuatorAnalysis(analysisId = 3,
                                       description = "Hidradenitis suppurativa incident", #change to name of phenotype algorithm cohort
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)
#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =2215) #change to first phenotype algorithm cohort ID to test

analysis4 <- createPheValuatorAnalysis(analysisId = 4,
                                       description = "Hidradenitis suppurativa incident with second code 31 to 365 days post index",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)

#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3768) #change to first phenotype algorithm cohort ID to test

analysis5 <- createPheValuatorAnalysis(analysisId = 5,
                                       description = "Hidradenitis suppurativa prevalent", #o name of phenotype algorithm cohort
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)
#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3769) #change to first phenotype algorithm cohort ID to test

analysis6 <- createPheValuatorAnalysis(analysisId = 6,
                                       description = "Hidradenitis suppurativa prevalent with second code 31 to 365 days post index",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)

#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3770) #change to first phenotype algorithm cohort ID to test

analysis7 <- createPheValuatorAnalysis(analysisId = 7,
                                       description = "Hidradenitis suppurativa prevalent codes Kim 2 codes",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)
#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3771) #change to first phenotype algorithm cohort ID to test

analysis8 <- createPheValuatorAnalysis(analysisId = 8,
                                       description = "Hidradenitis suppurativa prevalent codes Kim 3 codes",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)
#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3772) #change to first phenotype algorithm cohort ID to test

analysis9 <- createPheValuatorAnalysis(analysisId = 9,
                                       description = "Hidradenitis suppurativa prevalent codes Kim 4 codes",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)
#################################
AlgTestArgs <- createTestPhenotypeAlgorithmArgs(phenotypeCohortId =3773) #change to first phenotype algorithm cohort ID to test

analysis10 <- createPheValuatorAnalysis(analysisId = 10,
                                       description = "Hidradenitis suppurativa prevalent codes Kim 5 codes",
                                       createEvaluationCohortArgs = CohortArgs,
                                       testPhenotypeAlgorithmArgs = AlgTestArgs)


#can add/remove cohorts to test by copying/deleting createTestPhenotypeAlgorithmArgs() and createPheValuatorAnalysis() as above

pheValuatorAnalysisList <- list(analysis1, analysis2, analysis3, analysis4,analysis5,analysis6,analysis7,analysis8,analysis9,analysis10) #add/remove analyses
connectionSpecifications <- cdmSources %>%
  dplyr::filter(sequence == 1) %>%
  dplyr::filter(database == 'optum_extended_dod')

dbms <- connectionSpecifications$dbms 
port <- connectionSpecifications$port 
server <-
  connectionSpecifications$server 
cdmDatabaseSchema <-
  connectionSpecifications$cdmDatabaseSchema 
resultsDatabaseSchema <- connectionSpecifications$resultsDatabaseSchema
vocabDatabaseSchema <-
  connectionSpecifications$vocabDatabaseSchema 
databaseId <-
  connectionSpecifications$database 
userNameService = "redShiftUserName" 
passwordService = "redShiftPassword"
cohortDatabaseSchema = paste0('scratch_', keyring::key_get(service = userNameService))


connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  user = keyring::key_get(service = userNameService),
  password = keyring::key_get(service = passwordService),
  port = port,
  server = server
)

OHDA_RSSpec <- list(databaseId = databaseId, 
                         cdmDatabaseSchema = cdmDatabaseSchema, 
                         cohortDatabaseSchema = resultsDatabaseSchema, 
                         cohortTable = "cohort", 
                         workDatabaseSchema = cohortDatabaseSchema,
                         connectionDetails = createConnectionDetails(dbms = dbms, 
                                                                     connectionString =  paste("jdbc:redshift://ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com:5439/optum_extended_dod?ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory", sep=""), 
                                                                     user = keyring::key_get(service = userNameService),  
                                                                     password = keyring::key_get(service = passwordService))) 


referenceTable <- runPheValuatorAnalyses(connectionDetails = OHDA_RSSpec$connectionDetails,
                                         cdmDatabaseSchema = OHDA_RSSpec$cdmDatabaseSchema,
                                         cohortDatabaseSchema = OHDA_RSSpec$cohortDatabaseSchema,
                                         cohortTable = OHDA_RSSpec$cohortTable,
                                         workDatabaseSchema = OHDA_RSSpec$workDatabaseSchema,
                                         outputFolder = outFolder,
                                         pheValuatorAnalysisList = pheValuatorAnalysisList)

savePheValuatorAnalysisList(pheValuatorAnalysisList, file.path(outFolder, "pheValuatorAnalysisSettings.json"))
View(summarizePheValuatorAnalyses(referenceTable, outFolder), paste0("Results", OHDA_RSSpec$databaseId))

readr::write_excel_csv(x = summarizePheValuatorAnalyses(referenceTable, outFolder), na = "", 
                       file = paste0(outFolder, "/", databaseId, "_results.csv"), 
                       append = FALSE)


#gather up phevaluator files and combine

dbs <- c('CCAE', 'MDCD', 'MDCR', 'OPTUMEHR', 'OPTUMDOD')
databaseId <- c('truven_ccae', 'truven_mdcd', 'truven_mdcr', 'optum_ehr', 'optum_extended_dod')

outFolder <- 'D:/StudyResults/2021/HSPaper/Phevaluator/'
results3 <- data.frame()

for (i in (1:length(dbs))) {

  
 results <- read.csv(file = paste0(outFolder, dbs[i], '/', databaseId[i], "_results.csv"))
 results2 <- cbind(databaseId[i], results)
 results2$cohortId <- ifelse(results2$analysisId == 1, 3662,  
                             ifelse(results2$analysisId == 2, 3664,  
                                    ifelse(results2$analysisId == 3, 2214,
                                           ifelse(results2$analysisId == 4, 2215,
                                                  ifelse(results2$analysisId == 5, 3768,
                                                         ifelse(results2$analysisId == 6, 3769,
                                                                ifelse(results2$analysisId == 7, 3770,
                                                                       ifelse(results2$analysisId == 8, 3771,
                                                                              ifelse(results2$analysisId == 9, 3772, 3773)))))))))
 
 results3 <- rbind(results2, results3)

}
write.csv(results3, file = paste0(outFolder, "Phevaluator.csv"))
