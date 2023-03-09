package uk.gov.legislation.cites.gate;

import gate.creole.ExecutionException;
import gate.creole.ResourceInstantiationException;

import java.io.IOException;

abstract class GateEnricher {

    public abstract String enrich(String clml) throws IOException, ResourceInstantiationException, ExecutionException;

}
