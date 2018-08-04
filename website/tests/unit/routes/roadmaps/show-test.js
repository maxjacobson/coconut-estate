import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | roadmaps/show', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:roadmaps/show');
    assert.ok(route);
  });
});
