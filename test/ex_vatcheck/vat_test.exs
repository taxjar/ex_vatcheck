defmodule ExVatcheck.VATTest do
  use ExUnit.Case

  alias ExVatcheck.VAT

  describe "normalize/1" do
    test "capitalizes input VAT numbers" do
      assert VAT.normalize("gb123456789") == "GB123456789"
    end

    test "strips punctuation and whitespace" do
      assert VAT.normalize("GB . 123 - 456 ; 789") == "GB123456789"
    end

    test "properly handles UTF-8 characters" do
      assert VAT.normalize("GB123–––456(╯°□°）╯︵ ┻━┻)789") == "GB123456789"
    end
  end
end
