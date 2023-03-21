---
sidebar_position: 3
---

# Architecture

## QS

`QS.cls`

The main class. Contains all necessary methods to build SOQL and execute it.

## QB_Sub

`QB_Sub.cls`

Allows to build subQuery. Can be used by invoking `QS.Sub`.

## QB_ConditionsGroup

Builds dynamic conditions, set conitions order. It can store either `QB_ConditionsGroup` and `QB_Condition`. Can be used by invoking `QS.ConditionsGroup`.

## QB_Condition

Build atomic condition and do dynamic binding. Can be used by invoking `QS.Condition`.

## QB_Join

Constructs Join Query. It works with `QB_Condition`. Can be used by invoking `QS.Join`.

## QB

`QB.cls`

Stores all SOQL clauses and build SOQL String.

## QB_Binder

`QB_Binder.cls`

Keeps QS dynamic `WHERE` binding values.

## QB_Executor

`QB_Executor.cls`

Executes SOQL query. It also controlls FLS and Sharing modes.

## QB_Components

Keeps all classes that are responsible for SOQL construction.

![Image](./assets/Architecture.svg)
