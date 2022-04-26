package org.ldbcouncil.impls.workloads.ldbc.snb.postgres;

import org.ldbcouncil.driver.DbException;
import org.ldbcouncil.impls.workloads.ldbc.snb.QueryStore;
import org.ldbcouncil.impls.workloads.ldbc.snb.converter.Converter;
import org.ldbcouncil.impls.workloads.ldbc.snb.postgres.converter.PostgresConverter;

import java.util.HashMap;
import java.util.Map;

public class PostgresQueryStore extends QueryStore {

    protected Converter getConverter() {
        return new PostgresConverter();
    }

    public PostgresQueryStore(String path) throws DbException {
        super(path, ".sql");
    }

}
