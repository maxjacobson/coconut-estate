import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | roadmap-show', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    this.set('roadmap', { name: "My great roadmap", createdAt: 1532141843 });

    // Template block usage:
    await render(hbs`{{roadmap-show roadmap=roadmap}}`);

    assert.equal(true, this.element.textContent.trim().match(new RegExp('My great roadmap')) !== null);
  });
});
