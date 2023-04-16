import 'package:defi/src/presentation/shared/utils/color.dart';
import 'package:defi/src/services/auth/bloc/auth_bloc.dart';
import 'package:defi/src/services/auth/repo/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';

import '../../../services/wallet/firestore.dart';
import '../../../services/wallet/wallet_creation.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? pubAddress;
  String? privAddress;

  bool uninitialized = true;

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
    loadWalletDetails();
  }

  Future loadWalletDetails() async {
    dynamic data = await getUserDetails();
    setState(() {
      uninitialized = false;
    });
    data != null
        ? setState(() {
            privAddress = data['privateKey'];
            pubAddress = data['publicKey'];
          })
        : setState(() {});
  }

  bool get walletLoaded => (pubAddress != null && privAddress != null);

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    return Scaffold(
      body: SafeArea(
        child: uninitialized
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: !walletLoaded
                    ? Center(
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 54,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(ColorUtils.primary),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onPressed: () async {
                              WalletAddress service = WalletAddress();
                              final mnemonic = service.generateMnemonic();
                              final privateKey =
                                  await service.getPrivateKey(mnemonic);
                              final publicKey =
                                  await service.getPublicKey(privateKey);
                              privAddress = privateKey;
                              pubAddress = publicKey.toString();
                              setState(() {});
                              addUserDetails(privateKey, publicKey);
                            },
                            child: const Text(
                              'Activate Wallet',
                            ),
                          ),
                        ),
                      )
                    : Wallet(authRepository: authRepository),
              ),
      ),
    );
  }
}

class Wallet extends StatefulWidget {
  const Wallet({
    Key? key,
    required this.authRepository,
  }) : super(key: key);

  final AuthRepository authRepository;

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late Client httpClient;
  late Web3Client ethClient;
  String privAddress = "";
  String publicAddress = "";
  EthereumAddress targetAddress =
      EthereumAddress.fromHex("0xdf8837418830013cE287A876a226A689Fc0c30f0");
  bool? created;
  BigInt? balance;
  var credentials;
  int myAmount = 5000;

  bool uninitialized = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        'https://rinkeby.infura.io/v3/31af0756350d4018977972ef7a78fd32',
        httpClient);
    loadWalletDetails();
  }

  loadWalletDetails() async {
    dynamic data = await getUserDetails();
    if (data != null) {
      privAddress = data['privateKey'];
      publicAddress = data['publicKey'];
      var temp = EthPrivateKey.fromHex(privAddress);
      credentials = temp.address;
      created = data['wallet_created'];
      await getBalance(credentials);
      uninitialized = false;
      setState(() {});
    } else {
      print('Data is null');
    }
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi/abi.json");
    String contractAddress = "0x8c3290D833B2C8416b4d2AcA968472Bf37397008";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "FinalCoinFix"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(EthereumAddress credentialAddress) async {
    List<dynamic> result = await query("balanceOf", [credentialAddress]);
    var data = result[0];
    setState(() {
      balance = data;
    });
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("transfer", [targetAddress, bigAmount]);
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    EthPrivateKey key = EthPrivateKey.fromHex(privAddress);
    Transaction transaction = await Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000);
    print(transaction.nonce);
    final result =
        await ethClient.sendTransaction(key, transaction, chainId: 4);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return uninitialized
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: SizedBox(
                        height: 22,
                        width: 22,
                        child: Image.asset('assets/coin.png')),
                  ),
                  Text(
                    balance!.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthEventLogout());
                    },
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  widget.authRepository.user!.email,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 32),
                height: 420,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: QrImage(
                    data: widget.authRepository.user!.email,

                    version: QrVersions.auto,
                    // size: 200.0,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.maxFinite,
                height: 54,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ColorUtils.primary),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onPressed: () async {
                    // var res = await sendCoin();
                    // await getBalance(credentials);
                    // print(res);
                    String barcodeScanRes =
                        await FlutterBarcodeScanner.scanBarcode(
                            '0xFFFFFFF', 'Cancel', true, ScanMode.QR);
                  },
                  child: const Text(
                    'Pay',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.maxFinite,
                height: 54,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ColorUtils.primary),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onPressed: () async {
                    Share.share(publicAddress,
                        subject: 'Here\'s my Auram Hash');
                  },
                  child: const Text(
                    'Share Key',
                  ),
                ),
              ),
            ]),
          );
  }
}
