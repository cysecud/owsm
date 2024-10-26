package examplerego

import rego.v1

state["counter"] := data.counter - 1 if allow

default allow := false

allow if {
	data.counter > 0
	input.source == "x"
}
