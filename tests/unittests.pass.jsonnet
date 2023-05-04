local spin = import '../spin.libsonnet';

// Basic unittesting for methods that are not exercised by the other e2e-ish tests
// spin.libsonnet
std.assertEqual(true, true) &&
std.assertEqual(spin.nameToId(true), 'true') &&
std.assertEqual(spin.nameToId(1), '1') &&
std.assertEqual(spin.nameToId('My Application Name'), 'my-application-name') &&
std.assertEqual(spin.nameToId('My Application Name To Be Truncated Because Too Long'), 'my-application-name-to-be-truncated-') &&
true
