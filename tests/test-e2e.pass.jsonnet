local spin = import '../spin.libsonnet';

// Simple stack to exercise spin.libsonnet.

local appName = 'e2e';
local email = 'me@example.com';

local app = spin.application(appName, email);

local pipeline = spin.pipeline('deploy', appName);

local project = spin.project('end-to-end', email) + {
  config+: {
    applications+: app.name,
    pipelineConfigs+: [
      {
        application: app.name,
        pipelineConfigId: pipeline.name,
      },

    ],
  },
};

{
  ['application-' + appName]: app,
  ['pipeline-' + appName + '-' + pipeline.name]: pipeline,
  ['project-' + project.name]: project,
}
