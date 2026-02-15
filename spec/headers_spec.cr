require "./spec_helper"

describe Kemal::Inertia::Headers do
  it "defines INERTIA constant" do
    Kemal::Inertia::Headers::INERTIA.should eq("X-Inertia")
  end

  it "defines VERSION constant" do
    Kemal::Inertia::Headers::VERSION.should eq("X-Inertia-Version")
  end

  it "defines LOCATION constant" do
    Kemal::Inertia::Headers::LOCATION.should eq("X-Inertia-Location")
  end

  it "defines PARTIAL_DATA constant" do
    Kemal::Inertia::Headers::PARTIAL_DATA.should eq("X-Inertia-Partial-Data")
  end

  it "defines PARTIAL_EXCEPT constant" do
    Kemal::Inertia::Headers::PARTIAL_EXCEPT.should eq("X-Inertia-Partial-Except")
  end

  it "defines PARTIAL_COMPONENT constant" do
    Kemal::Inertia::Headers::PARTIAL_COMPONENT.should eq("X-Inertia-Partial-Component")
  end

  it "defines ERROR_BAG constant" do
    Kemal::Inertia::Headers::ERROR_BAG.should eq("X-Inertia-Error-Bag")
  end

  it "defines RESET constant" do
    Kemal::Inertia::Headers::RESET.should eq("X-Inertia-Reset")
  end

  it "defines EXCEPT_ONCE_PROPS constant" do
    Kemal::Inertia::Headers::EXCEPT_ONCE_PROPS.should eq("X-Inertia-Except-Once-Props")
  end

  it "defines VARY constant" do
    Kemal::Inertia::Headers::VARY.should eq("Vary")
  end
end
