import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midgard_repository/midgard_repository.dart';
import 'package:thorswapalyzer/swapaction/bloc/swapaction_bloc.dart';
import 'package:thorswapalyzer/utils/layout/size_config.dart';

class SwapPage extends StatefulWidget {
  SwapPage({Key? key}) : super(key: key);

  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  SizeConfig _size = SizeConfig();
  TextEditingController _textEditingController = TextEditingController();
  late SwapActionBloc _swapActionBloc;

  @override
  void initState() {
    _swapActionBloc = BlocProvider.of<SwapActionBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size.init(context);
    return Scaffold(
      body: BlocListener(
          bloc: _swapActionBloc,
          listener: ((context, SwapActionState state) {
            if (state is SwapActionActiveState) {
              state.action.inputShort == 'ETH'
                  ? _textEditingController.text = '0X' + state.thorTX.txID
                  : _textEditingController.text = state.thorTX.txID;
            }
          }),
          child: Container(
              width: _size.paneWidth,
              height: _size.paneHeight,
              color: Color(0xFFEEF4EF),
              child: BlocBuilder(
                  bloc: _swapActionBloc,
                  builder: (context, SwapActionState state) {
                    return _swapActionLayout(state);
                  }))),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        backgroundColor: Color(0xFF23DCC8),
        tooltip: 'Donate!',
        heroTag: 'Feeling Generous?',
        child: Icon(FontAwesomeIcons.donate),
        onPressed: () {
          _showDonateDialog(context);
        },
      ),
    );
  }

  Widget _swapActionLayout(SwapActionState state) {
    if (state is SwapActionEmptyState) {
      // display input widget only
      return Stack(children: [
        Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("SWAPALYZER OF THOR",
              style:
                  GoogleFonts.firaCode(fontSize: _size.blockSizeVertical * 4)),
          SizedBox(height: _size.blockSizeVertical * 5),
          Container(
              height: _size.blockSizeVertical * 40,
              child: Image(
                image: AssetImage('assets/swapalyzerofthor.png'),
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              )),
          SizedBox(height: _size.blockSizeVertical * 5),
          _swapActionInput()
        ]))
      ]);
    } else if (state is SwapActionActiveState) {
      // display results + input
      return Stack(children: [
        Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                _swapActionInput(),
                SizedBox(height: _size.blockSizeVertical * 3),
                _swapActionDisplay(state)
              ],
            ))
      ]);
    }
    // else
    return Center(child: CircularProgressIndicator());
  }

  Widget _swapActionInput() =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: _size.blockSizeHorizontal * 70,
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  fillColor: Color(0x00CCFF),
                  focusColor: Color(0x00CCFF),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff282C34), width: 3.0),
                  ),
                  labelText: 'Input Transaction ID',
                  labelStyle: GoogleFonts.firaCode()),
              style: GoogleFonts.firaCode(),
              onSubmitted: (text) {
                Navigator.pushNamed(context, '/swap/$text');
              },
            )),
      ]);

  Widget _swapActionDisplay(SwapActionActiveState state) {
    final double paneWidth = _size.blockSizeHorizontal * 62;
    final double sentUSD = (state.action.inputsTotal *
        (state.action.inputShort == "RUNE"
            ? state.runeUSD.runeUSD
            : state.pools[state.action.inputAsset]!.assetPrice));
    final double inFeeUSD = (state.thorTX.input.fees[0].amount *
        (state.action.inputShort == "RUNE"
            ? state.runeUSD.runeUSD
            : state.pools[state.action.inputAsset]!.assetPrice));
    final double outFeeUSD = ((state.thorTX.output!.fees[0].amount * 3) *
        (state.action.outputShort == "RUNE"
            ? state.runeUSD.runeUSD
            : state.pools[state.thorTX.output?.fees[0].asset]!.assetPrice));
    final double swapFeeUSD =
        ((state.action.metadata as SwapMetaData).liquidityFee *
            state.runeUSD.runeUSD);
    final double recUSD = (state.action.outputsTotal *
        (state.action.outputShort == "RUNE"
            ? state.runeUSD.runeUSD
            : state.pools[state.action.outputAsset]!.assetPrice));
    var diff = sentUSD - recUSD;
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0XFFE2DEDE)),
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20.0),
        ),
        width: paneWidth,
        height: _size.blockSizeVertical * 85,
        child: SingleChildScrollView(
            child: Column(
          children: [
            _horizontalMultiSection(state, width: paneWidth - 2, titles: [
              'Time:',
              'Block Height:'
            ], bodies: [
              state.action.date.toLocal().toString().split('.')[0].substring(
                  0,
                  state.action.date.toLocal().toString().split('.')[0].length -
                      3),
              '${state.action.height.toString()}'
            ]),
            Divider(),
            _horizontalMultiSection(state, width: paneWidth - 2, titles: [
              'Status:',
              'RUNE:'
            ], bodies: [
              state.action.status,
              '\$${state.runeUSD.runeUSD.toStringAsFixed(2)}'
            ]),
            Divider(),
            _horizontalSingleSection(
              state,
              width: paneWidth - 2,
              title: 'Sent:',
              body:
                  '${state.action.inputsTotal.toString()} ${state.action.inputShort} | \$' +
                      sentUSD.toStringAsFixed(2) +
                      ' USD',
            ),
            Divider(),
            _horizontalSingleSection(state,
                width: paneWidth - 2,
                title: 'Swap Fee:',
                body:
                    '${(state.action.metadata as SwapMetaData).liquidityFee.toStringAsFixed(2)} RUNE | \$' +
                        swapFeeUSD.toStringAsFixed(2) +
                        ' USD'),
            Divider(),
            _horizontalSingleSection(state,
                width: paneWidth - 2,
                title: 'In Fee:',
                body:
                    '${state.thorTX.input.fees[0].amount} ${state.action.inputShort} | \$' +
                        inFeeUSD.toStringAsFixed(2) +
                        ' USD'),
            Divider(),
            _horizontalSingleSection(state,
                width: paneWidth - 2,
                title: 'Out Fee:',
                body:
                    '${state.thorTX.output?.fees[0].amount} ${state.thorTX.output!.fees[0].assetShort} | \$' +
                        outFeeUSD.toStringAsFixed(2) +
                        ' USD'),
            Divider(),
            _horizontalSingleSection(state,
                width: paneWidth - 2,
                title: 'Received:',
                body:
                    '${state.action.outputsTotal.toStringAsFixed(4)} ${state.action.outputShort} | \$' +
                        recUSD.toStringAsFixed(2) +
                        ' USD'),
            Divider(),
            _horizontalMultiSection(state, width: paneWidth - 2, titles: [
              'Expected Cost:',
              'Real (+/-):'
            ], bodies: [
              '\$' +
                  (swapFeeUSD + inFeeUSD + outFeeUSD).toStringAsFixed(2) +
                  ' USD',
              (!diff.isNegative
                  ? '-' + '\$' + diff.toStringAsFixed(2) + ' USD'
                  : '+ ' + '\$' + diff.toStringAsFixed(2) + ' USD')
            ]),
          ],
        )));
  }

  Widget _horizontalSingleSection(SwapActionActiveState state,
          {String title = '', String body = '', required width}) =>
      Container(
        height: _size.blockSizeVertical * 8,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                  left: _size.blockSizeHorizontal * 2,
                  top: _size.blockSizeVertical * 1.5),
              child: SelectableText(
                title,
                style: GoogleFonts.firaCode(
                    fontWeight: FontWeight.bold,
                    fontSize: _responsiveFontSize(
                        width: width, maxSize: 12, multiplier: 4)),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: _size.blockSizeVertical * 4.5),
              child: SelectableText(body,
                  style: GoogleFonts.firaCode(
                    fontSize: _responsiveFontSize(
                        width: width, maxSize: 16, multiplier: 4),
                  )),
            )
          ],
        ),
      );

  double _responsiveFontSize(
          {required double width,
          required double maxSize,
          required double multiplier}) =>
      width / 100 * multiplier < maxSize ? width / 100 * multiplier : maxSize;

  Widget _horizontalMultiSection(SwapActionActiveState state,
          {required List<String> titles,
          required List<String> bodies,
          required double width}) =>
      Container(
          height: _size.blockSizeVertical * 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var x in titles)
                Container(
                    width: width / titles.length,
                    child: Stack(
                      children: [
                        Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(
                                left: _size.blockSizeHorizontal * 2,
                                top: _size.blockSizeVertical * 1.5),
                            child: SelectableText(
                              x,
                              style: GoogleFonts.firaCode(
                                  fontSize: _responsiveFontSize(
                                      width: width, maxSize: 12, multiplier: 4),
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                top: _size.blockSizeVertical * 4.5),
                            child: SelectableText(
                              bodies[
                                  titles.indexWhere((element) => element == x)],
                              style: GoogleFonts.firaCode(
                                fontSize: _responsiveFontSize(
                                    width: width, maxSize: 16, multiplier: 4),
                              ),
                            )),
                        x != titles.last
                            ? Container(
                                alignment: Alignment.centerRight,
                                child: VerticalDivider())
                            : Container()
                      ],
                    )),
            ],
          ));

  void _showDonateDialog(BuildContext context) {
    // set up the buttons
    final donateRUNE = TextButton(
      child: Text("Donate BTC",
          style: GoogleFonts.firaCode(color: Color(0xFF23DCC8))),
      onPressed: () {
        Clipboard.setData(
            ClipboardData(text: "bc1q4879m7qxhxa09sc2jjhddx0q9077n7fyqmy2gp"));
        final snackBar = SnackBar(
            content: Text(
          'BTC address copied! May the stars of Asgard shine upon thee.',
          style: GoogleFonts.firaSans(),
        ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      },
    );
    final donateBTC = TextButton(
      child: Text("Donate RUNE",
          style: GoogleFonts.firaCode(color: Color(0xFF23DCC8))),
      onPressed: () {
        Clipboard.setData(
            ClipboardData(text: "thor1ndf9xxrw6cchp3xp9840jh6qn8tmt8zey6hpqe"));
        final snackBar = SnackBar(
            content: Text(
                'RUNE address copied! May the stars of Asgard shine upon thee.',
                style: GoogleFonts.firaSans()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      },
    );
    final cancel = TextButton(
      child: Text(
        "Cancel",
        style: GoogleFonts.firaCode(color: Color(0xFFFF4954)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      title: Text("Help us build more!",
          style: GoogleFonts.firaSans(fontWeight: FontWeight.bold)),
      content: Text(
        'Want OFTHOR to build bigger and better projects for THORChain?' +
            ' Help us with a donation or grant by clicking the buttons below to copy our address to your clipboard.',
        style: GoogleFonts.firaSans(),
      ),
      actions: [
        donateRUNE,
        donateBTC,
        cancel,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
