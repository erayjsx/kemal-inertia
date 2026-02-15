require "./spec_helper"

enum TestColor
  Red
  Green
  Blue
end

struct TestUser
  include JSON::Serializable

  getter name : String
  getter age : Int32

  def initialize(@name : String, @age : Int32)
  end
end

describe Kemal::Inertia::Serializer do
  describe ".to_any" do
    it "serializes nil" do
      result = Kemal::Inertia::Serializer.to_any(nil)
      result.raw.should be_nil
    end

    it "serializes String" do
      result = Kemal::Inertia::Serializer.to_any("hello")
      result.as_s.should eq("hello")
    end

    it "serializes Int32" do
      result = Kemal::Inertia::Serializer.to_any(42_i32)
      result.as_i64.should eq(42_i64)
    end

    it "serializes Int64" do
      result = Kemal::Inertia::Serializer.to_any(100_i64)
      result.as_i64.should eq(100_i64)
    end

    it "serializes Float32" do
      result = Kemal::Inertia::Serializer.to_any(3.14_f32)
      result.as_f.should be_close(3.14, 0.01)
    end

    it "serializes Float64" do
      result = Kemal::Inertia::Serializer.to_any(2.718)
      result.as_f.should be_close(2.718, 0.001)
    end

    it "serializes Bool true" do
      result = Kemal::Inertia::Serializer.to_any(true)
      result.as_bool.should be_true
    end

    it "serializes Bool false" do
      result = Kemal::Inertia::Serializer.to_any(false)
      result.as_bool.should be_false
    end

    it "serializes Symbol" do
      result = Kemal::Inertia::Serializer.to_any(:hello)
      result.as_s.should eq("hello")
    end

    it "serializes Time as RFC3339" do
      time = Time.utc(2025, 1, 15, 10, 30, 0)
      result = Kemal::Inertia::Serializer.to_any(time)
      result.as_s.should contain("2025-01-15")
    end

    it "serializes Array" do
      result = Kemal::Inertia::Serializer.to_any([1, 2, 3])
      arr = result.as_a
      arr.size.should eq(3)
      arr[0].as_i64.should eq(1)
      arr[2].as_i64.should eq(3)
    end

    it "serializes Hash" do
      result = Kemal::Inertia::Serializer.to_any({"name" => "Alice", "age" => 30})
      hash = result.as_h
      hash["name"].as_s.should eq("Alice")
      hash["age"].as_i64.should eq(30)
    end

    it "serializes NamedTuple" do
      result = Kemal::Inertia::Serializer.to_any({name: "Bob", active: true})
      hash = result.as_h
      hash["name"].as_s.should eq("Bob")
      hash["active"].as_bool.should be_true
    end

    it "serializes Tuple as Array" do
      result = Kemal::Inertia::Serializer.to_any({1, "two", 3.0})
      arr = result.as_a
      arr.size.should eq(3)
      arr[0].as_i64.should eq(1)
      arr[1].as_s.should eq("two")
      arr[2].as_f.should eq(3.0)
    end

    it "serializes Enum" do
      result = Kemal::Inertia::Serializer.to_any(TestColor::Green)
      result.as_s.should eq("Green")
    end

    it "serializes JSON::Serializable" do
      user = TestUser.new(name: "Charlie", age: 25)
      result = Kemal::Inertia::Serializer.to_any(user)
      hash = result.as_h
      hash["name"].as_s.should eq("Charlie")
      hash["age"].as_i64.should eq(25)
    end

    it "serializes JSON::Any passthrough" do
      original = JSON::Any.new("passthrough")
      result = Kemal::Inertia::Serializer.to_any(original)
      result.as_s.should eq("passthrough")
    end

    it "serializes nested structures" do
      data = {
        "users" => [
          {"name" => "Alice", "age" => 30},
          {"name" => "Bob", "age" => 25},
        ],
      }
      result = Kemal::Inertia::Serializer.to_any(data)
      users = result.as_h["users"].as_a
      users.size.should eq(2)
      users[0].as_h["name"].as_s.should eq("Alice")
    end

    it "serializes empty Array" do
      result = Kemal::Inertia::Serializer.to_any([] of String)
      result.as_a.size.should eq(0)
    end

    it "serializes empty Hash" do
      result = Kemal::Inertia::Serializer.to_any({} of String => String)
      result.as_h.size.should eq(0)
    end
  end
end
