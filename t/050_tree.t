use strict;
use warnings FATAL => 'all';

use Test::More tests => 4;
use Data::Dumper;

BEGIN { use_ok('HTML::Tested::Value::Tree'); }

use constant INPUT_TREE => [ {
	value => 'a',
	children => [ {
		value => 'b',
		children => [ {
			value => 'g',
		} ],
	}, {
		value => 'c',
		children => [ {
			value => 'f',
		} ],
	} ]
}, {
	value => 'e',
} ];

is(HTML::Tested::Value::Tree->value_to_string('name', { input_tree => INPUT_TREE,
collapsed_format => '%value%', selected_format => '%value% 1',
selection_attribute => "value", selection_tree => {
	a => { c => { f => 1 } },
} }), <<ENDS);
<ul>
  <li>
    a 1
    <ul>
      <li>
        b
      </li>
      <li>
        c 1
        <ul>
          <li>
            f 1
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    e
  </li>
</ul>
ENDS

is(HTML::Tested::Value::Tree->value_to_string('name', { input_tree => INPUT_TREE,
selection_attribute => "value", selection_tree => {
	a => { c => { f => 1 } },
} }), <<ENDS);
<ul>
  <li>
    <span class="selected">a</span>
    <ul>
      <li>
        <a href="#">b</a>
      </li>
      <li>
        <span class="selected">c</span>
        <ul>
          <li>
            <span class="selected">f</span>
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    <a href="#">e</a>
  </li>
</ul>
ENDS

is(HTML::Tested::Value::Tree->value_to_string('name', { input_tree => INPUT_TREE,
selection_attribute => "value", selections => [ 'e', 'f' ], }), <<ENDS);
<ul>
  <li>
    <span class="selected">a</span>
    <ul>
      <li>
        <a href="#">b</a>
      </li>
      <li>
        <span class="selected">c</span>
        <ul>
          <li>
            <span class="selected">f</span>
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    <span class="selected">e</span>
  </li>
</ul>
ENDS
