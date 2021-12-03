library(PheValuator)
library(OutputPhevaluator)

options(scipen = 999)

drive <- "d"
machine <- 4203
condition <- "slePRMethod"
dataFolder <- "ProjectData/PheValuator"
codeFolder <- "PhenotypeLibrary"

xSpecCohort <- 22370
excludedCovariateConceptIds <- c()
xSensCohort <- 22371
prevalenceCohort <- 7796
evaluationPopulationCohortId <- 22372

options(andromedaTempFolder = paste0(drive, ":/temp2/ff"))
options(fftempdir = paste0(drive, ":/temp2/ff"))

folder <- paste0(drive, ":/", dataFolder, "/", condition)

dir.create(file.path(folder), showWarnings = FALSE)

oracleTempSchema <- NULL

# Create analysis settings ----------------------------------------------------------------------------------------
CovSettingsAcute <- createDefaultAcuteCovariateSettings(excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                        addDescendantsToExclude = FALSE,
                                                        startDayWindow1 = 0,
                                                        endDayWindow1 = 30,
                                                        startDayWindow2 = 31,
                                                        endDayWindow2 = 365,
                                                        startDayWindow3 = 366,
                                                        endDayWindow3 = 9999)

modelType <- "acute"

CohortArgsAcute <- createCreateEvaluationCohortArgs(xSpecCohortId = xSpecCohort,
                                                    xSensCohortId = xSensCohort,
                                                    prevalenceCohortId = prevalenceCohort,
                                                    evaluationPopulationCohortId = evaluationPopulationCohortId,
                                                    evaluationPopulationCohortIdStartDay = 0,
                                                    evaluationPopulationCohortIdEndDay = 0,
                                                    xSpecCohortSize = 5000,
                                                    covariateSettings = CovSettingsAcute,
                                                    baseSampleSize = 2000000,
                                                    lowerAgeLimit = 18,
                                                    visitType = c(9201,9202,9203, 581477),
                                                    visitLength = 0,
                                                    startDate = "20100101",
                                                    endDate = "21000101",
                                                    excludeModelFromEvaluation = FALSE,
                                                    saveEvaluationCohortPlpData = FALSE,
                                                    modelType = modelType)

##### First phenotype algorithm to test ##############
conditionAlg1TestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints = c("EV"),
                                                          phenotypeCohortId =  xSpecCohort, #CHANGE THIS: 1st phenotype algorithm to test
                                                          washoutPeriod = 0) #CHANGE THIS: to how many continuous observation days prior to index (e.g., 365)

analysis1 <- createPheValuatorAnalysis(analysisId = 1,
                                       description = "xSpec", #CHANGE THIS: to a good name for your phenotype algorithm to test
                                       createEvaluationCohortArgs = CohortArgsAcute,
                                       testPhenotypeAlgorithmArgs = conditionAlg1TestArgs)

##### Second phenotype algorithm to test - delete if not testing more algorithms ##############
conditionAlg2TestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                          phenotypeCohortId = prevalenceCohort,
                                                          washoutPeriod = 0)

analysis2 <- createPheValuatorAnalysis(analysisId = 2,
                                       description = "Prevalence",
                                       createEvaluationCohortArgs = CohortArgsAcute,
                                       testPhenotypeAlgorithmArgs = conditionAlg2TestArgs)

### Algorithms to test
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23083,
                                                         washoutPeriod = 0)

analysis3 <- createPheValuatorAnalysis(analysisId = 3,
                                       description = "[460] Systemic Lupus 3X plus ever anti-malarial drugs (per Barnardo, 2017)",
                                       createEvaluationCohortArgs = CohortArgsAcute,
                                       testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

##
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23084,
                                                         washoutPeriod = 0)

analysis4 <- createPheValuatorAnalysis(analysisId = 4,
                                       description = "[460] Systemic Lupus 3X plus ever anti-malarial drugs excluding  DM and SSc (per Barnardo, 2017)",
                                       createEvaluationCohortArgs = CohortArgsAcute,
                                       testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

##
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23035,
                                                         washoutPeriod = 0)

analysis10 <- createPheValuatorAnalysis(analysisId = 10,
                                        description = "[EPI882] Systemic lupus erythematosus incident and correction for index date V2",
                                        createEvaluationCohortArgs = CohortArgsAcute,
                                        testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

##
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23036,
                                                         washoutPeriod = 0)

analysis11 <- createPheValuatorAnalysis(analysisId = 11,
                                        description = "[EPI882] Systemic lupus erythematosus incident with 2nd dx and correction for index date V2",
                                        createEvaluationCohortArgs = CohortArgsAcute,
                                        testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

##
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23039,
                                                         washoutPeriod = 0)

analysis12 <- createPheValuatorAnalysis(analysisId = 12,
                                        description = "[EPI882] Systemic lupus erythematosus prevalent and correction for index date V2",
                                        createEvaluationCohortArgs = CohortArgsAcute,
                                        testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

##
conditionAlgTestArgs <- createTestPhenotypeAlgorithmArgs(cutPoints =  c("EV"), #CHANGE THIS: same instructions as for analysis 1
                                                         phenotypeCohortId = 23040,
                                                         washoutPeriod = 0)

analysis13 <- createPheValuatorAnalysis(analysisId = 13,
                                        description = "[EPI882] Systemic lupus erythematosus prevalent with 2nd dx and correction for index date V2",
                                        createEvaluationCohortArgs = CohortArgsAcute,
                                        testPhenotypeAlgorithmArgs = conditionAlgTestArgs)

pheValuatorAnalysisList <- list(analysis1, analysis2, analysis3, analysis4, analysis10,
                                analysis11, analysis12, analysis13) #include in the list all the analyses from above

CCAE_RSSpec <- list(databaseId = "CCAE_RS", 
                    cdmDatabaseSchema = "cdm", 
                    cohortDatabaseSchema = "ohdsi_results", 
                    cohortTable = "cohort", 
                    workDatabaseSchema = "scratch_jswerdel_ccae",
                    connectionDetails = createConnectionDetails(dbms = "redshift", 
                                                                connectionString = paste("jdbc:redshift://rhealth-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com:5439/truven_ccae?ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory", sep=""), 
                                                                user = user, 
                                                                password = pword))

dbList <- list(CCAE_RSSpec)

savePheValuatorAnalysisList(pheValuatorAnalysisList, file.path(folder, "pheValuatorAnalysisSettings.json"))

for (dbUp in 1:length(dbList)) {
  pheValuatorAnalysisList <- loadPheValuatorAnalysisList(file.path(folder, "pheValuatorAnalysisSettings.json"))
  
  outFolder <- file.path(folder, paste0(dbList[[dbUp]]$databaseId))
  
  referenceTable <- runPheValuatorAnalyses(connectionDetails = dbList[[dbUp]]$connectionDetails,
                                           cdmDatabaseSchema = dbList[[dbUp]]$cdmDatabaseSchema,
                                           cohortDatabaseSchema = dbList[[dbUp]]$cohortDatabaseSchema,
                                           cohortTable = dbList[[dbUp]]$cohortTable,
                                           workDatabaseSchema = dbList[[dbUp]]$workDatabaseSchema,
                                           outputFolder = outFolder,
                                           pheValuatorAnalysisList = pheValuatorAnalysisList)
  
  View(summarizePheValuatorAnalyses(referenceTable, outFolder), paste0("Results", dbList[[dbUp]]$databaseId))
  
}

