// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// ============================================================
// JAGUAR TOKEN - POLYGON (ERC-20)
// OpenZeppelin Contracts 5.x
//
// STATUS: PROPOSTA PARA TESTES LOCAIS / POLYGON AMOY.
// NAO PUBLICAR NA MAINNET SEM TESTES COMPLETOS E AUDITORIA.
// ============================================================

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract JaguarToken is ERC20, Ownable2Step {

    uint256 private constant UM_TOKEN = 10 ** 18;

    uint256 public constant SUPPLY_TOTAL =
        2_000_000_000 * UM_TOKEN;

    uint256 public constant MAX_TRANSFERENCIA =
        10_000_000 * UM_TOKEN;

    uint256 public constant MAX_CARTEIRA =
        40_000_000 * UM_TOKEN;

    address public immutable CARTEIRA_PRINCIPAL;

    bool public mercadoAberto;

    event MercadoAbertoAlterado(bool aberto);

    error SaidaMuitoGrande();
    error CarteiraMuitoGrande();
    error EnderecoInvalido();
    error RenunciaDesativada();
    error MercadoFechado();
    error EstadoJaDefinido();

    constructor(
        address carteiraPrincipal,
        address donoInicial
    )
        ERC20("Jaguar Token", "JAGUAR")
        Ownable(donoInicial)
    {
        if (
            carteiraPrincipal == address(0) ||
            donoInicial == address(0)
        ) {
            revert EnderecoInvalido();
        }

        CARTEIRA_PRINCIPAL = carteiraPrincipal;

        _mint(carteiraPrincipal, SUPPLY_TOTAL);
    }

    // ABRIR E FECHAR O MERCADO

    function definirMercadoAberto(
        bool aberto
    ) external onlyOwner {
        if (mercadoAberto == aberto) {
            revert EstadoJaDefinido();
        }

        mercadoAberto = aberto;

        emit MercadoAbertoAlterado(aberto);
    }

    // PROTECOES ANTI-BALEIA

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        if (from != address(0) && to != address(0)) {
            // MERCADO FECHADO
            if (
                !mercadoAberto &&
                from != CARTEIRA_PRINCIPAL &&
                to != CARTEIRA_PRINCIPAL
            ) {
                revert MercadoFechado();
            }

            // LIMITE POR TRANSFERENCIA
            if (value > MAX_TRANSFERENCIA) {
                revert SaidaMuitoGrande();
            }

            // LIMITE DE CARTEIRA
            if (
                to != CARTEIRA_PRINCIPAL &&
                to != from
            ) {
                if (balanceOf(to) + value > MAX_CARTEIRA) {
                    revert CarteiraMuitoGrande();
                }
            }
        }

        super._update(from, to, value);
    }

    // BLOQUEAR RENUNCIA DE PROPRIEDADE

    function renounceOwnership()
        public
        pure
        override
    {
        revert RenunciaDesativada();
    }
}

