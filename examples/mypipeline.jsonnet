local spin = import '../spin.libsonnet';

// Short example to show creating a pipeline and using composition to extend
// the pipeline stages array.
// With jsonnet composition we can override or extend anywhere in our pipeline.

// Create a Wait pipeline stage and set some values for clarity.
local wait1 = spin.wait() + {
  name: 'Wait 1',
  refId: 'wait1',
};

// Create a second Wait pipeline stage that waits for 5 seconds and requires
// the first Wait stage above to complete (sequential).
local wait2 = spin.wait() + {
  name: 'Wait 2',
  refId: 'wait2',
  requisiteStageRefIds: [wait1.refId],
  waitTime: 5,
};

// Create a pipeline with a single stage.
local pipeline = spin.pipeline('mypipeline', 'myapp') + {
  stages+: [
    wait1,
  ],
};

// Output pipeline but use composition to include an additional stage.
pipeline {
  stages+: [
    // stage array ordering not important, ordering derived from requisiteStageRefIds.
    wait2,
  ],
}
