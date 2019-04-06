# ExVatcheck

An Elixir Package for verifying VAT identification numbers using the
[VIES](http://ec.europa.eu/taxation_customs/vies/) service.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_vatcheck` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_vatcheck, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_vatcheck](https://hexdocs.pm/ex_vatcheck).

## Development

### Testing

To run the full test suite, run:

```
$ mix test
```

To run the test suite with a code coverage report, run:

```
$ mix test --cover
```

### Linting

To run the linter, run:

```
$ mix credo
```

### Type Analysis

To run static type analysis on the project using Dialyzer, run the following command:

```
$ mix dialyzer
```

The first time this command is run, it will first generate the PLT for the Elixir
standard library. It can take a little while, but subsequent Dialyzer runs should
be take a fraction of the time. The compiled PLT is saved at
`~/.dialyxir_core_${OTP_VERSION}_${ELIXIR_VERSION}.plt`. More information about
the PLT can be found here: https://github.com/jeremyjh/dialyxir#plt.
