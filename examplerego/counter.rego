package examplerego

import rego.v1

state["counter"] := data.counter - 1 if allow

default allow := false

allow if {
	input.source == "x"
	data.counter > 0
}
