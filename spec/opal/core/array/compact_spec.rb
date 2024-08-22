# backtick_javascript: true

describe "Array#compact" do
  it "compacts nil and JavaScript null and undefined" do
    a = [1, nil, `null`, `undefined`]
    expect(a.size).to eq 4
    expect(a.compact.size).to eq 1
    a.compact!
    expect(a.size).to eq 1
  end
end