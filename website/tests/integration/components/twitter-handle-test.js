import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | twitter-handle', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    this.set('handle', 'hello');
    await render(hbs`{{twitter-handle handle=handle}}`);

    assert.equal(this.element.textContent.trim(), '@hello');
  });
});
