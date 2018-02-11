import React from 'react';
import ReactDOM from 'react-dom';
import {Container, Row, Col, Button} from 'reactstrap';

export default function run_demo(root, channel) {
    ReactDOM.render(<Game channel={channel}/>, root);
}


// const initialState = {
//     score: 0,
//     arrayElements: [[{value: 'A', display: false}, {value: 'D', display: false}, {
//         value: 'H',
//         display: false
//     }, {value: 'G', display: false}],
//         [{value: 'B', display: false}, {value: 'D', display: false}, {value: 'E', display: false}, {
//             value: 'F',
//             display: false
//         }],
//         [{value: 'F', display: false}, {value: 'H', display: false}, {value: 'A', display: false}, {
//             value: 'B',
//             display: false
//         }],
//         [{value: 'C', display: false}, {value: 'G', display: false}, {value: 'E', display: false}, {
//             value: 'C',
//             display: false
//         }]],
//     clickable: true
// };


class Game extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel;
        this.state = {
            arrayElements: [[{}, {}, {}, {}], [{}, {}, {}, {}], [{}, {}, {}, {}], [{}, {}, {}, {}]],
            score: 0, clickable: false
        };

        this.channel.join()
            .receive("ok", view => this.gotView(view))
            .receive("error", resp => {
                console.log("Unable to join", resp)
            });
    }

    gotView(view) {
        // console.log("Before this view is called");
        // console.log(this.state);
        // console.log("This is sent by the server");
        // console.log(view.game);
        this.setState(view.game, function() {
            console.log("After this view is called");
            console.log(this.state);
        });
    }

    /* The shuffling of array logic has been referenced from stackoverflow.com */
    shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    render() {
        console.log("Render inside root");
        console.log(this.state);
        return (
            <Container>
                <Table rootObj={this}/>
                <Score rootObj={this}/>
                <Button onClick={() => this.reset()}>RESET</Button>
            </Container>
        );
    }

    updatePrev(tile) {
        this.setState(_.extend(this.state, {prev: tile}))
    }

    reset() {
        let initialStateCopy = JSON.parse(JSON.stringify(initialState));
        this.shuffleArray(initialStateCopy.arrayElements);
        initialStateCopy.arrayElements.forEach(this.shuffleArray);
        this.setState(initialStateCopy);
    }

    updateScore() {
        console.log("Update score is called");
        this.state.score = ++this.state.score;
    }

    toggleClickable() {
        console.log("toggleCLickable() is called. Present value: " + this.state.clickable);
        this.state.clickable = !this.state.clickable;
    }

    updateState(state) {
        console.log("update state is called with state: " + state);
        this.setState(state);
    }

    updateState(state, fn) {
        this.setState(state, fn);
    }

    handleClick(prevValue) {
        if (this.state.prev) {
            console.log("This state previous is present");
            if (prevValue.tile.value != this.state.prev.tile.value) {
                console.log("Values not matched");
                prevValue.tile.display = true;
                this.setState(this.state, function (){
                    let thisObj = this;
                    setTimeout(function () {
                        thisObj.channel.push("guess", {clicked: thisObj.state.prev, prev: false})
                            .receive("ok", (view) => thisObj.gotView(view));
                    }, 1000)
                })
            }
            else {
                console.log("Values matched");
                this.channel.push("guess", {clicked: prevValue, prev: false})
                    .receive("ok", (view) => this.gotView(view));
            }
        }
        else    {
            console.log("This state previous is absent");
            this.channel.push("guess", {clicked: prevValue, prev: true})
                .receive("ok", (view) => this.gotView(view));}
    }
}

class Score extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div>Score: {this.props.rootObj.state.score}</div>
        );
    }

}

class Table extends React.Component {
    constructor(props) {
        super(props);
        this.state = {arrayElements: props.rootObj.state.arrayElements};
    }

    componentWillReceiveProps(props) {
        this.setState({arrayElements: props.rootObj.state.arrayElements});
    }

    render() {

        return (
            this.state.arrayElements.map((elm, i) => {
                return <Row>{elm.map((tile, j) => <Tile tileObj={tile} location={{i: i, j: j}}
                                                        rootObj={this.props.rootObj}/>)}</Row>
            })
        );
    }
}

class Tile extends React.Component {
    constructor(props) {
        // console.log("Tile constructor is created");
        super(props);
        this.state = {tile: props.tileObj, location: props.location};
    }

    componentWillReceiveProps(props) {
        // console.log(props.tileObj);
        this.setState({tile: props.tileObj, location: props.location});
    }

    render() {
        return (
            <div className="col-3 border"
                 onClick={() => !this.state.tile.display && this.props.rootObj.handleClick(this.state)}>
                {this.state.tile.display ? this.state.tile.value : " "}
            </div>
        );
    }

    handleClick() {
        console.log("handle click is working");
        if (!this.props.rootObj.state.arrayElements.every((ele) => {
                return ele.every((e) => {
                    return e.display;
                })
            })) {

            // let scoreValue = this.state.score;
            // scoreValue = scoreValue + 1;
            // let copyArr = this.state.arrayElements;
            let rootState = this.props.rootObj.state;
            let rootObj = this.props.rootObj;
            let state = this.state;
            if (!state.display) {
                console.log("handle click is working");
                rootObj.toggleClickable();

                if (!rootState.prev) {
                    console.log("I am here");
                    state.display = true;
                    console.log(this.props.rootObj.state);
                    rootState.prev = state;
                    rootObj.updateScore();
                    rootObj.toggleClickable();
                    rootObj.setState(rootState);
                }

                else {
                    if (!(rootState.prev == state) && rootState.prev.value == state.value) {
                        state.display = true;
                        delete rootState.prev;
                        rootObj.updateScore();
                        rootObj.toggleClickable();
                        rootObj.setState(rootState);
                    }

                    else {
                        state.display = true;
                        rootObj.setState(rootState, function () {
                            let rootOb = rootObj;
                            setTimeout(function () {
                                state.display = false;
                                rootState.prev.display = false;
                                delete rootState.prev;
                                ++rootState.score;
                                rootState.clickable = !rootState.clickable;
                                // rootOb.updateScore();
                                // rootOb.toggleClickable();
                                // // let rootStateCopy = JSON.parse(JSON.stringify(rootState));
                                rootOb.setState(rootState);
                            }, 1000)
                        });
                    }
                }
            }
        }
    }
}