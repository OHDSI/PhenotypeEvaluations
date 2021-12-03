remotes::install_github("OHDSI/CohortDiagnostics")
Sys.setenv(TZ="America/New_York")


packageName <- "HS"
library(CohortDiagnostics)
connectionSpecifications <- cdmSources %>%
  dplyr::filter(sequence == 1) %>%
  dplyr::filter(database == 'ims_australia_lpd')

dbms <- connectionSpecifications$dbms 
port <- connectionSpecifications$port 
server <-
  connectionSpecifications$server 
cdmDatabaseSchema <-
  connectionSpecifications$cdmDatabaseSchema
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

cohortTable <- 
  paste0("s", connectionSpecifications$sourceId, "_", packageName)
temporaryLocation <- file.path("D:/StudyResults/2021/HSPaper", "outputFolder", databaseId)
outputFolder <-
  file.path("D:/StudyResults/2021/HSPaper", "outputFolder", databaseId)

dir.create(path = outputFolder,
           showWarnings = FALSE,
           recursive = TRUE)

library(magrittr)
# Set up
baseUrl <- 'https://epi.jnj.com:8443/WebAPI'
# list of cohort ids
cohortIds <- c(2214, 2215, 3768, 3769, 3770, 3771, 3772, 3773)

# get specifications for the cohortIds above
webApiCohorts <-
  ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl) %>%
  dplyr::filter(.data$id %in% cohortIds)

cohortsToCreate <- list()
for (i in (1:nrow(webApiCohorts))) {
  cohortId <- webApiCohorts$id[[i]]
  cohortDefinition <-
    ROhdsiWebApi::getCohortDefinition(cohortId = cohortId, 
                                      baseUrl = baseUrl)
  cohortsToCreate[[i]] <- tidyr::tibble(
    atlasId = webApiCohorts$id[[i]],
    atlasName = stringr::str_trim(string = stringr::str_squish(cohortDefinition$name)),
    cohortId = webApiCohorts$id[[i]],
    name = stringr::str_trim(stringr::str_squish(cohortDefinition$name))
  )
}
cohortsToCreate <- dplyr::bind_rows(cohortsToCreate)

readr::write_excel_csv(x = cohortsToCreate, na = "", 
                       file = file.path("D:/StudyResults/2021/HSPaper", "outputFolder", databaseId, "CohortsToCreate.csv"), 
                       append = FALSE)


cohortSetReference <- readr::read_csv(file = file.path("D:/StudyResults/2021/HSPaper", "outputFolder", databaseId, "CohortsToCreate.csv"), 
                                      col_types = readr::cols())

CohortDiagnostics::instantiateCohortSet(connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                        cohortTable = cohortTable,
                                        baseUrl = baseUrl,
                                        cohortSetReference = cohortSetReference,
                                        generateInclusionStats = TRUE,
                                        inclusionStatisticsFolder = file.path(outputFolder, 
                                                                              'inclusionStatisticsFolder'))

 CohortDiagnostics::runCohortDiagnostics(baseUrl = baseUrl,
                                        cohortSetReference = cohortSetReference,
                                        connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                        cohortTable = cohortTable,
                                        inclusionStatisticsFolder = file.path(outputFolder, 
                                                                              'inclusionStatisticsFolder'),
                                        exportFolder = file.path(outputFolder, 
                                                                 'exportFolder'),
                                        databaseId = databaseId,
                                        runInclusionStatistics = TRUE,
                                        runIncludedSourceConcepts = TRUE,
                                        runOrphanConcepts = TRUE,
                                        runTimeDistributions = TRUE,
                                        runBreakdownIndexEvents = TRUE,
                                        runIncidenceRate = TRUE,
                                        runCohortOverlap = TRUE,
                                        runCohortCharacterization = TRUE,
                                        minCellCount = 5)


dataFolder <- "D:/StudyResults/2021/HSPaper/zipFiles"
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = dataFolder)

CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = dataFolder)
