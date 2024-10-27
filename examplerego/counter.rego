package examplerego

import rego.v1

state["counter"] := data.counter - 1 if allow

default allow := false

allow if {
	input.user == "fabio"
	data.counter > 0
}
