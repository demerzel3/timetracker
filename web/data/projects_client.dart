part of timetracker;

class ProjectsClient extends CouchDbClient<Project> {
  ProjectsClient(http, serverUrl) : super(http, serverUrl, "projects", (rawData) => new Project.fromJson(rawData));
}