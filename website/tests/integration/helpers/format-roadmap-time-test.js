import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Helper | format-roadmap-time', function(hooks) {
  setupRenderingTest(hooks);

  // Replace this with your real tests.
  test('it renders', async function(assert) {
    this.set('inputValue', 1532141625);

    await render(hbs`{{format-roadmap-time inputValue 'friendly'}}`);

    assert.equal(this.element.textContent.trim(), 'July 20th 2018, 10:53 PM');
  });
});
