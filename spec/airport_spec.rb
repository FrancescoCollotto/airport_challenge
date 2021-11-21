require 'airport'
require 'plane'

describe Airport do
  let(:gatwick) { described_class.new }
  let(:wings) { Plane.new }
  
  context "land" do
    it "instruct a plane to land" do
      expect(gatwick).to respond_to(:land).with(1).argument
    end
    it "land a plane in the airport" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      expect(gatwick.land(wings)).to eq wings
    end
    it "prevent landing when airport is full" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      allow(gatwick).to receive(:full) { true }
      expect { gatwick.land(wings) }.to raise_error("The airport is full, redirecting somewhere else")
    end
    it "prevent landing if plane already landed" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      gatwick.land(wings)
      expect { gatwick.land(wings) }.to raise_error("The aeroplane has already landed")
    end
    it "prevent landing if plane already landed somewhere else" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      luton = Airport.new
      allow(luton).to receive(:forecast) { "sunny" }
      luton.land(wings)
      expect { gatwick.land(wings) }.to raise_error("The aeroplane has already landed in another airport")
    end
  end

  context "take off" do
    it "instruct a plane to take off" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      expect(gatwick).to respond_to(:departure).with(1).argument
    end
    it "let landed planes to take off from an airport" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      gatwick.land(wings)
      expect(gatwick.departure(wings)).to eq wings
    end
    it "prevent plane to take off if not landed in the airport" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      gatwick.land(Plane.new)
      expect { gatwick.departure(wings) }.to raise_error("The aeroplane is not in the airport")
    end
    it "checks departed planes are no longer store in airport" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      gatwick.land(wings)
      10.times { gatwick.land(Plane.new)}
      gatwick.departure(wings)
      expect(gatwick.landed).not_to include(wings)
    end
  end

  context "airport capacity" do
    it "has a default capacity of 50" do
      expect(Airport::DEFAULT_CAPACITY).to eq 50
    end
    it "can be overriden to other number" do
      stanstead = Airport.new(35)
      expect(stanstead.capacity).to eq 35
    end
    it "report full when reach capacity" do
      allow(gatwick).to receive(:forecast) { "sunny" }
      50.times { gatwick.land(Plane.new) }
      expect(gatwick.full).to eq true
    end
  end

  context "weather" do
    it "prevent take off when weather is stormy" do
      allow(gatwick).to receive(:forecast) { "stormy" }
      expect { gatwick.departure(wings) }.to raise_error("Stormy weather, red light for departure")
    end
    it "prevent landing when weather is stormy" do
      allow(gatwick).to receive(:forecast) { "stormy" }
      expect { gatwick.land(wings) }.to raise_error("Stormy weather, red light for landing")
    end
    it "randomly return 'sunny' or 'stormy'" do
      expect(gatwick.forecast).to eq('sunny').or eq('stormy')
    end
  end

end