library(CohortDiagnostics)
codeFolder <- "d:/PhenotypeLibrary"
folder <- "d:/CohortDiagnostics/data/SLE_All"


tempTable <- paste0("cohortDiag")

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

allCohorts <- read.csv("./cohorts/cohortListSLE.csv")
cohortsToCD <- allCohorts[is.na(allCohorts$compare),] #under 99999 are cohorts in the cohort table
cohortsToCompare <- allCohorts[!is.na(allCohorts$compare),] #over 99999 are special designated cohorts

for(dbUp in 1:length(dbList)) {
  CohortDiagnostics:::createCohortTable(connectionDetails = dbList[[dbUp]]$connectionDetails,
                                        cohortDatabaseSchema = dbList[[dbUp]]$workDatabaseSchema,
                                        cohortTable = tempTable)
  
  baseUrl <- "https://epi.jnj.com:8443/WebAPI"
  ROhdsiWebApi::authorizeWebApi(baseUrl, "windows") # Windows
  
  CohortDiagnostics::instantiateCohortSet(connectionDetails = dbList[[dbUp]]$connectionDetails,
                                          cdmDatabaseSchema = dbList[[dbUp]]$cdmDatabaseSchema,
                                          oracleTempSchema = NULL,
                                          cohortDatabaseSchema = dbList[[dbUp]]$workDatabaseSchema,
                                          cohortTable = tempTable,
                                          baseUrl = baseUrl,
                                          createCohortTable = FALSE,
                                          cohortSetReference = cohortsToCD)
  
  for(compareUp in 1:nrow(cohortsToCompare)) {
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "CreateCohortCompare.sql",
                                             packageName = "OutputPhevaluator",
                                             cdm_database_schema = dbList[[dbUp]]$cdmDatabaseSchema,
                                             cohort_database_schema = dbList[[dbUp]]$workDatabaseSchema,
                                             cohort_database_table = tempTable,
                                             original_cohort_id = cohortsToCompare$compare[[compareUp]],
                                             compare_cohort_id  = cohortsToCompare$atlasId[[compareUp]],
                                             compare_count = 10,
                                             look_back = cohortsToCompare$lookback[[compareUp]])
    DatabaseConnector::executeSql(connection = DatabaseConnector::connect(dbList[[dbUp]]$connectionDetails), sql)
  }
  
  dbList[[dbUp]]$cohortDatabaseSchema <- dbList[[dbUp]]$workDatabaseSchema
  dbList[[dbUp]]$cohortTable <- tempTable 
  
  outFolder <- file.path(folder, dbList[[dbUp]]$databaseId)
  
  ROhdsiWebApi::authorizeWebApi(baseUrl, "windows") # Windows
  CohortDiagnostics::runCohortDiagnostics(baseUrl = baseUrl,
                                          cohortSetReference = allCohorts,
                                          connectionDetails = dbList[[dbUp]]$connectionDetails,
                                          cdmDatabaseSchema = dbList[[dbUp]]$cdmDatabaseSchema,
                                          cohortDatabaseSchema = dbList[[dbUp]]$cohortDatabaseSchema,
                                          cohortTable = dbList[[dbUp]]$cohortTable,
                                          inclusionStatisticsFolder = file.path(outFolder, 
                                                                                'inclusionStatisticsFolder'),
                                          exportFolder = file.path(outFolder, 
                                                                   'exportFolder'),
                                          databaseId = dbList[[dbUp]]$databaseId,
                                          runInclusionStatistics = TRUE,
                                          runIncludedSourceConcepts = TRUE,
                                          runOrphanConcepts = FALSE,
                                          runTimeDistributions = TRUE,
                                          runBreakdownIndexEvents = TRUE,
                                          runIncidenceRate = TRUE,
                                          runCohortOverlap = TRUE,
                                          runCohortCharacterization = TRUE,
                                          runTemporalCohortCharacterization = TRUE,
                                          minCellCount = 5,
                                          incremental = FALSE, 
                                          incrementalFolder = file.path(outFolder, 
                                                                        'exportFolder'))
  
}

dataFolder <- "d:/CohortDiagnostics/data/SLE_All"
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = dataFolder)

CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = dataFolder)
