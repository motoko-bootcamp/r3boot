import Principal "mo:base/Principal";
import Map "mo:map/Map";

import Memory "../../../utilities/memory";
module Ledger {

	public type Action = {
		#transfer : Transfer;
		#mint : Mint;
	};

	public type Transfer = {
		from : Principal;
		to : Principal;
		amount : Nat;
	};

	public type Mint = {
		to : Principal;
		amount : Nat;
	};

	public type Ledger = actor {
		transact : shared (action : Action) -> async ();
	};

	public type RootState = {
		var ledger : Map.Map<Principal, Nat>;
		var self : Principal;
	};

	public type LeafState = {
		var root : Principal;
		var self : Principal;
	};

	public func initRoot(
		self : Principal
	) : Memory.State<RootState> {
		Memory.init<RootState>({
			var ledger = Map.new<Principal, Nat>();
			var self = self;
		});
	};

	public func initLeaf(
		root : Principal,
		self : Principal
	) : Memory.State<LeafState> {
		Memory.init<LeafState>({
			var root = root;
			var self = self;
		});
	};

};
