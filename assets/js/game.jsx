import React from 'react';
import ReactDOM from 'react-dom';
import {Container, Row, Col, Button} from 'reactstrap';

export default function run_demo(root, channel) {
    ReactDOM.render(<Game channel={channel}/>, root);
}

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
        this.setState(view.game);
    }

    render() {
        return (
            <Container>
                <Table rootObj={this}/>
                <Score rootObj={this}/>
                <Button onClick={() => this.reset()}>RESET</Button>
            </Container>
        );
    }

    reset() {
        this.channel.push("reset")
            .receive("ok", view => this.gotView(view))
            .receive("error", resp => {
                console.log("Unable to join", resp)
            });
    }

    handleClick(prevValue) {
        this.state.clickable = false;
        if (this.state.prev) {
            if (prevValue.tile.value != this.state.prev.tile.value) {
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
                this.channel.push("guess", {clicked: prevValue, prev: false})
                    .receive("ok", (view) => this.gotView(view));
            }
        }
        else    {
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
        super(props);
        this.state = {tile: props.tileObj, location: props.location};
    }

    componentWillReceiveProps(props) {
        this.setState({tile: props.tileObj, location: props.location});
    }

    render() {
        return (
            <div className="col-3 border"
                 onClick={() => !this.state.tile.display &&
                     this.props.rootObj.state.clickable &&
                     this.props.rootObj.handleClick(this.state)
                    }>
                {this.state.tile.display ? this.state.tile.value : " "}
            </div>
        );
    }
}