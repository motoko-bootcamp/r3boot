import Error "mo:base/Error";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Memory "../../utilities/memory";
import Version1 "./state/v1";
module Ledger {

	public let VERSION = (0, 0, 1);
	public let NAME = "Ledger";
	public let DESCRIPTION = "The ledger for the R3boot network";

	public module State = {
		public let V1 = Version1;
	};

	private let ERROR_PREFIX = "Error in Ledger : ";
	private let MAXIMUM_SUPPLY = 21_000_000;

	public type Action = Version1.Action;
	public type Transfer = Version1.Transfer;
	public type Mint = Version1.Mint;
	public type Ledger = Version1.Ledger;
	public type RootState = Version1.RootState;
	public type LeafState = Version1.LeafState;

	public class Root(stored : Memory.State<RootState>) {
		var state = Memory.load<RootState>(stored);

		public func mint(
			_caller : Principal,
			mint : Mint
		) : async* () {
			let { to; amount } = mint;
			let toBalance = Option.get(Map.get<Principal, Nat>(state.ledger, phash, to), 0);
			if (toBalance + amount <= MAXIMUM_SUPPLY) {
				Map.set<Principal, Nat>(state.ledger, phash, to, toBalance + amount);
			} else {
				throw (Error.reject(ERROR_PREFIX # "Exceeds maximum supply"));
			};
		};

		public func transfer(
			caller : Principal,
			transfer : Transfer
		) : async* () {
			assert (caller == transfer.from);

			let { to; from; amount } = transfer;

			let fromBalance = Option.get(Map.get<Principal, Nat>(state.ledger, phash, from), 0);
			let toBalance = Option.get(Map.get<Principal, Nat>(state.ledger, phash, to), 0);

			if (fromBalance >= transfer.amount) {
				Map.set<Principal, Nat>(state.ledger, phash, from, fromBalance - amount);
				Map.set<Principal, Nat>(state.ledger, phash, to, toBalance + amount);
			} else {
				throw (Error.reject(ERROR_PREFIX # "Insufficient funds"));
			};
		};

		public func balance(
			caller : Principal
		) : Nat {
			let balance = Option.get(Map.get<Principal, Nat>(state.ledger, phash, caller), 0);
			balance;
		};

	};

	public class Leaf(stored : Memory.State<LeafState>) {
		var state = Memory.load<LeafState>(stored);

		public func transact(
			action : Action
		) : async* Result.Result<(), Text> {
			let ledger : Ledger = actor (Principal.toText(state.root));
			try {
				await ledger.transact(action);
				return #ok();
			} catch (e) {
				return #err(Error.message(e));
			};
		};
	};

};
