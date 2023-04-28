// Generic library of Spinnaker objects
//
// Inspired by https://github.com/bitnami-labs/kube-libsonnet
// Favouring composition over a builder pattern

{
  // Helper functions

  // nameToId converts input string to suitable Spinnaker Id string
  // Spinnaker generated Id: "id": "c09b2c8f-871f-4a36-90e0-220bfe69ab99"
  // known constraints: string, 36 character length, hyphenated, lowercase
  // function not attempting to check presence of special chars
  nameToId(name)::
    local n0 = std.toString(name);
    local n1 = std.substr(n0, 0, 36);
    local n2 = std.asciiLower(n1);
    std.strReplace(n2, ' ', '-'),

  // Spinnaker functions


  // Project components

  projectCluster(name):: {
    account: name,
    applications: null,
    detail: '*',
    stack: '*',
  },

  project(name, email):: {
    config: {
      applications: [],
      clusters: [],  // array of projectCluster(name) objects
      pipelineConfigs: [],  // objects of { application: "myapp", pipelineConfigId: "mypipeline" }
    },
    email: email,
    id: $.nameToId(name),  // it's confusing for two projects to have the same name, enforce id
    name: name,
  },


  // Application components

  application(name, email, cloudProviders='kubernetes'):: {
    cloudProviders: cloudProviders,  // required key
    email: email,
    name: name,
    user: email,
  },

  // Pipeline Components

  pipeline(name, app):: {
    name: name,
    application: app,
    keepWaitingPipelines: false,
    limitConcurrent: true,
  },

  // Artifacts

  customArtifact(name, version):: {
    displayName: name,
    id: name,
    matchArtifact: {
      artifactAccount: 'custom-artifact',
      customKind: true,
      name: name,
      reference: name,
      type: 'custom/object',
      version: version,
    },
    useDefaultArtifact: false,
    usePriorArtifact: true,
  },

  dockerArtifact(repository, account):: {
    defaultArtifact: {
      artifactAccount: account,
      kind: 'default.docker',
      name: repository,
      reference: repository,
      type: 'docker/image',
    },
    displayName: repository,
    id: repository,
    matchArtifact: {
      artifactAccount: account,
      kind: 'docker',
      name: repository,
      type: 'docker/image',
    },
    useDefaultArtifact: false,
    usePriorArtifact: true,
  },

  embeddedArtifact(name):: {
    displayName: name,
    id: name,
    matchArtifact: {
      artifactAccount: 'embedded-artifact',
      id: name,
      name: name,
      type: 'embedded/base64',
    },
    useDefaultArtifact: false,
    usePriorArtifact: true,
  },

  gitlabArtifact(path, baseUrl, account):: {
    defaultArtifact: {
      artifactAccount: account,
      kind: 'default.gitlab',
      name: path,
      reference: baseUrl + std.strReplace(path, '/', '%2F') + '/raw',
      type: 'gitlab/file',
      version: 'master',
    },
    displayName: path,
    id: path,
    matchArtifact: {
      artifactAccount: account,
      kind: 'gitlab',
      name: path,
      type: 'gitlab/file',
    },
    useDefaultArtifact: true,
    usePriorArtifact: false,
  },

  s3Artifact(objectRegex, bucket, account):: {
    defaultArtifact: {
      artifactAccount: account,
      kind: 'default.s3',
      name: 's3://%s/%s' % [bucket, objectRegex],
      reference: 's3://%s/%s' % [bucket, objectRegex],
      type: 's3/object',
    },
    displayName: 's3://%s/%s' % [bucket, objectRegex],
    id: 's3://%s/%s' % [bucket, objectRegex],
    matchArtifact: {
      artifactAccount: account,
      kind: 's3',
      name: 's3://%s/%s' % [bucket, objectRegex],
      type: 's3/object',
    },
    useDefaultArtifact: false,
    usePriorArtifact: false,
  },


  // Notifications

  notification(address, level, message=null, type, when):: {
    address: address,
    level: level,
    message: message,
    type: type,
    when: when,
  },


  // Parameters

  parameter(name):: {
    default: '',
    description: '',
    hasOptions: false,
    label: '',
    name: name,
    options: [{ value: '' }],
    pinned: false,
    required: false,
  },


  // Stages

  manualJudgment():: {
    failPipeline: true,
    judgmentInputs: [],
    name: 'Manual Judgment',
    notifications: [],
    refId: 'Manual Judgment',
    requisiteStageRefIds: [],
    type: 'manualJudgment',
  },

  runPipeline(application, pipeline):: {
    application: application,
    failPipeline: true,
    name: 'Trigger pipeline %s/%s' % [application, pipeline],
    pipeline: pipeline,
    type: 'pipeline',
    waitForCompletion: false,
    refId: 'trigger-%s' % pipeline,
  },

  wait():: {
    name: 'Wait',
    refId: 'wait',
    requisiteStageRefIds: [],
    type: 'wait',
    waitTime: 30,
  },

  // Stages - Compute

  bake(application):: {
    amiName: application,
    baseLabel: 'release',
    baseName: application,
    baseOs: 'ubuntu',
    cloudProviderType: 'aws',
    extendedAttributes: {},
    name: 'Bake',
    refId: 'bake',
    regions: [],
    requisiteStageRefIds: [],
    storeType: 'ebs',
    type: 'bake',
    vmType: 'hvm',
  },

  cluster(application, keyPair, instanceType, subnetType, availabilityZones, account):: {
    account: account,
    application: application,
    availabilityZones: availabilityZones,
    capacity: {
      desired: 1,
      max: 1,
      min: 1,
    },
    cloudProvider: 'aws',
    cooldown: 10,
    copySourceCustomBlockDeviceMappings: false,
    ebsOptimized: false,
    enabledMetrics: [],
    freeFormDetails: '',
    healthCheckGracePeriod: 600,
    healthCheckType: 'EC2',
    instanceMonitoring: false,
    instanceType: instanceType,
    keyPair: keyPair,  // required by Spinnaker but not AWS, see: https://github.com/spinnaker/spinnaker/issues/4813
    loadBalancers: [],
    provider: 'aws',
    securityGroups: [],
    spotPrice: '',
    stack: '',
    strategy: '',
    subnetType: subnetType,
    suspendedProcesses: [],
    tags: {},
    targetGroups: [],
    targetHealthyDeployPercentage: 100,
    terminationPolicies: [
      'Default',
    ],
    useAmiBlockDeviceMappings: false,
  },


  deploy(clusters=[]):: {
    // build name from account and regions listed in any supplied clusters
    // eg: 'acc1 :: ap-southeast-1 ap-southeast-2 :::: acc2 :: us-east-2'
    local stageName = (
      if std.length(clusters) > 0 then std.join(' :::: ', [
        local regions = std.join(' ', std.objectFields(c.availabilityZones));
        '%s :: %s' % [c.account, regions]
        for c in clusters
      ]) else 'Deploy'
    ),
    clusters: clusters,
    name: stageName,
    refId: stageName,
    type: 'deploy',
  },

  // Stages - Kubernetes

  deployManifest(application, artifact, artifactId, account):: {
    account: account,
    cloudProvider: 'kubernetes',
    credentials: account,
    manifestArtifactId: artifactId,
    moniker: {
      app: application,
    },
    name: '%s :: %s' % [account, artifact],
    refId: '%s :: %s' % [account, artifact],
    requisiteStageRefIds: [],
    skipExpressionEvaluation: true,
    source: 'artifact',
    type: 'deployManifest',
  },

  runJobManifest(application, artifact, artifactId, account):: {
    account: account,
    alias: 'runJob',
    cloudProvider: 'kubernetes',
    credentials: account,
    manifestArtifactId: artifactId,
    moniker: {
      app: application,
    },
    name: 'JOB :: %s :: %s' % [account, artifact],
    refId: 'JOB :: %s :: %s' % [account, artifact],
    requisiteStageRefIds: [],
    skipExpressionEvaluation: true,
    source: 'artifact',
    type: 'runJobManifest',
  },

  scaleManifest(application, resourceKind, resourceName, namespace, replicas, account):: {
    account: account,
    app: application,
    cloudProvider: 'kubernetes',
    location: namespace,
    manifestName: '%s %s' % [resourceKind, resourceName],
    mode: 'static',
    name: 'SCALE to %s :: %s :: %s/%s' % [replicas, account, resourceKind, resourceName],
    refId: 'SCALE to %s :: %s :: %s/%s' % [replicas, account, resourceKind, resourceName],
    replicas: replicas,
    requisiteStageRefIds: [],
    type: 'scaleManifest',
  },

  // Stages - AWS

  resizeServerGroup(replicas, cluster, accounts, application, detail, stack, region):: {
    action: 'scale_exact',
    capacity: { desired: replicas, max: replicas, min: replicas },
    cloudProvider: 'aws',
    cloudProviderType: 'aws',
    cluster: cluster,
    credentials: accounts,
    moniker: {
      app: application,
      cluster: cluster,
      detail: detail,
      sequence: null,
      stack: stack,
    },
    name: 'SCALE to %s :: %s :: %s' % [replicas, accounts, cluster],
    refId: 'SCALE to %s :: %s :: %s' % [replicas, accounts, cluster],
    regions: [region],
    requisiteStageRefIds: [],
    resizeType: 'exact',
    target: 'current_asg_dynamic',
    targetHealthyDeployPercentage: 100,
    type: 'resizeServerGroup',
  },

  // Triggers

  cronTrigger(expr, runAsUser=null):: {
    cronExpression: expr,
    enabled: true,
    runAsUser: runAsUser,
    type: 'cron',
  },

  // TODO: reconsider - a lot of parameters here
  dockerTrigger(repository, tag, organization, registry, runAsUser=null, account):: {
    account: account,
    enabled: true,
    organization: organization,
    registry: registry,
    repository: repository,
    runAsUser: runAsUser,
    tag: tag,
    type: 'docker',
  },

  gitlabTrigger(expectedArtifactIds, branch, project, slug, runAsUser=null):: {
    branch: branch,
    enabled: true,
    expectedArtifactIds+: expectedArtifactIds,
    project: project,  // parent namespace - eg: gitlab.com/"myorg" or gitlab.com/group1/"group2"
    runAsUser: runAsUser,
    slug: slug,  // project name - eg: gitlab.com/myorg/"myproject"
    source: 'gitlab',
    type: 'git',
  },

  webhookTrigger(source, expectedArtifactIds=[], payloadConstraints=null, runAsUser=null):: {
    enabled: true,
    expectedArtifactIds+: expectedArtifactIds,
    runAsUser: runAsUser,
    source: source,  // application name
    type: 'webhook',
  },

  pipelineTrigger(application, pipeline, runAsUser=null):: {
    application: application,
    enabled: true,
    pipeline: pipeline,
    runAsUser: runAsUser,
    status: ['successful'],
    type: 'pipeline',
  },
}
