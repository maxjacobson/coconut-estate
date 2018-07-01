import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | roadmap-details', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    // Set any properties with this.set('myProperty', 'value');
    // Handle any actions with this.set('myAction', function(val) { ... });

    this.set('roadmap', { title: "My great roadmap" });
    await render(hbs`{{roadmap-details roadmap=roadmap}}`);

    assert.equal(this.element.textContent.trim(), 'My great roadmap');
  });
});
