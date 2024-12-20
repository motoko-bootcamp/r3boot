import Debug "mo:base/Debug";
import Option "mo:base/Option";

module Memory {
    public type State<S> = {
        var inner : ?S;
    };

    public func init<S>(state : S) : State<S> {
        { var inner = ?state }
    };

    public func unload<S>(state : State<S>) {
        state.inner := null;
    };

    public func load<S>(state : State<S>) : S {
        let ?s = state.inner else Debug.trap("Loading uninitialized module state");
        s
    };

    public func upgrade<Old, New>(from : State<Old>, transform : Old -> New) : State<New> {
        let ?oldState = from.inner else Debug.trap("Upgrading uninitialized module state");
        let newState = { var inner = ?transform(oldState) };
        unload(from);
        newState
    };

    public func hasUpgraded<A, B>(from : State<A>, to : State<B>) : Bool {
        Option.isNull(from.inner) or Option.isSome(to.inner)
    };
}