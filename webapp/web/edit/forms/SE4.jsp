<%--
Copyright (c) 2010, Cornell University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Cornell University nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>

<%@ page import="com.hp.hpl.jena.rdf.model.Literal"%>
<%@ page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@ page import="com.hp.hpl.jena.vocabulary.XSD" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.EditConfiguration"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils"%>

<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.validators.StartYearBeforeEndYear"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core"%>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>


<%! 
    public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.researchDataDescription.jsp");
%>
<%
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();    
    vreq.setAttribute("defaultNamespace", ""); //empty string triggers default new URI behavior
    String subjectUri = (String) request.getAttribute("subjectUri");
    String flagURI = null;
    //if (vreq.getAppBean().isFlag1Active()) {
        //flagURI = VitroVocabulary.vitroURI+"Flag1Value"+vreq.getPortal().getPortalId()+"Thing";
    //} else {
        flagURI = wdf.getVClassDao().getTopConcept().getURI();  // fall back to owl:Thing if not portal filtering
    //}
    vreq.setAttribute("flagURI",flagURI);
    
    request.setAttribute("stringDatatypeUriJson", MiscWebUtils.escape(XSD.xstring.toString()));
    request.setAttribute("dateDatatypeUriJson", MiscWebUtils.escape(XSD.date.toString()));
    request.setAttribute("booleanDatatypeUriJson", MiscWebUtils.escape(XSD.xboolean.toString()));
%>

<c:set var="vivoCore" value="http://vivoweb.org/ontology/core#" />
<%-- <c:set var="vitroands" value="http://www.ands.org.au/ontologies/ns/0.1/VITRO-ANDS.owl#" /> --%>
<c:set var="vitroands" value="http://purl.org/ands/ontologies/vivo/" />
<c:set var="rdfs" value="<%= VitroVocabulary.RDFS %>" />
<c:set var="label" value="${rdfs}label" />
<c:set var="researchDataClass" value="${vitroands}ResearchData" />

<c:set var="inheritedCustodians">
<sparql:sparql>
	      <sparql:select model="${applicationScope.jenaOntModel}" var="inforauthorships" publication="<${subjectUri}>">
	          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	      	  PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	          PREFIX bibo: <http://purl.org/ontology/bibo/>
	          PREFIX core: <http://vivoweb.org/ontology/core#>
	          SELECT ?person ?org ?plabel ?olabel WHERE{
		?publication core:informationResourceInAuthorship ?la.
		?la core:linkedAuthor ?person.
                ?person core:personInPosition ?position.
                ?position core:positionInOrganization ?org.
                ?person rdfs:label ?plabel.
                 ?org rdfs:label ?olabel}
	      </sparql:select>
					<c:forEach items="${inforauthorships.rows}" var="inforauthorship" varStatus="counter">
                                            <input type="hidden" disabled id="inferredStatementsAPI${counter.count}" name="inferredStatementsAPI${counter.count}" value="
						@prefix ands: <${vitroands}> .
                                                @prefix core: <${vivoCore}> .
                                                ?researchDataUri ands:associatedPrincipleInvestigator <${inforauthorship.person}> .
                                                <${inforauthorship.person}> ands:custodianOfResearchData ?researchDataUri  . 
						?researchDataUri ands:custodianDepartment <${inforauthorship.org}> . 
                                                 <${inforauthorship.org}> ands:custodianOfResearchData ?researchDataUri ." />
                                            <li>
                                                <div class="inferredStatements">
                                                    Associated Principle Investigator: ${inforauthorship.plabel} (Custodian Department: ${inforauthorship.olabel})
                                                    <div style="float: right">
                                                        <input type="checkbox" name="list" onclick="if(this.checked){checkBox(inferredStatementsAPI${counter.count})}else{unCheckBox(inferredStatementsAPI${counter.count})}"/>
                                                    </div>
                                                </div>
                                            </li>
					</c:forEach>
	  </sparql:sparql> 
</c:set>

<c:set var="inheritedSubjectArea">
<sparql:sparql>
	      <sparql:select model="${applicationScope.jenaOntModel}" var="subjectAreaSparql" publication="<${subjectUri}>">
	          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	      	  PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	          PREFIX bibo: <http://purl.org/ontology/bibo/>
	          PREFIX core: <http://vivoweb.org/ontology/core#>
	          SELECT ?subjectArea WHERE{
                    ?publication core:hasSubjectArea ?subjectArea .
                    ?subjectArea rdfs:label ?subjectAreaLabel
              }
	      </sparql:select>
					<c:forEach items="${subjectAreaSparql.rows}" var="subjectAreaResult" varStatus="counter">
                                            <input type="hidden" disabled id="inferredStatementsSA${counter.count}" name="inferredStatementsSA${counter.count}" value="
                                                @prefix ands: <${vitroands}> .
                                                @prefix core: <${vivoCore}> .
                                                ?researchDataUri core:hasSubjectArea <${subjectAreaResult.subjectArea}> ." />
                                            <li>
                                                <div class="inferredStatements">
                                                    Subject Area: ${subjectAreaResult.subjectAreaLabel}
                                                    <div style="float: right">
                                                        <input type="checkbox" name="list" onclick="if(this.checked){checkBox(inferredStatementsSA${counter.count})}else{unCheckBox(inferredStatementsSA${counter.count})}"/>
                                                    </div>
                                                </div>
                                            </li>
					</c:forEach>
	  </sparql:sparql>
</c:set>

<%--  Then enter a SPARQL query for each field, by convention concatenating the field id with "Existing"
      to convey that the expression is used to retrieve any existing value for the field in an existing individual.
      Each of these must then be referenced in the sparqlForExistingLiterals section of the JSON block below
      and in the literalsOnForm --%>

<c:set var="RDlabelPred" value="${rdfs}label" />

<v:jsonset var="researchDataLabelExisting" >  
    SELECT ?researchDataLabelExisting WHERE {
          ?researchDataUri <${RDlabelPred}> ?researchDataLabelExisting }
</v:jsonset>

<v:jsonset var="researchDataLabelAssertion" >      
    ?researchDataUri <${RDlabelPred}> ?researchDataLabel .
</v:jsonset>

<%-- <http://www.ands.org.au/ontologies/ns/0.1/VITRO-ANDS.owl#researchDataDescription> --%>

<c:set var="dataDescriptionPred" value="${vitroands}researchDataDescription" />
<v:jsonset var="dataDescriptionExisting" >  
    SELECT ?dataDescriptionExisting WHERE {
          ?researchDataUri <${dataDescriptionPred}> ?dataDescriptionExisting }
</v:jsonset>

<%--  Pair the "existing" query with the skeleton of what will be asserted for a new statement involving this field.
      The actual assertion inserted in the model will be created via string substitution into the ? variables.
      NOTE the pattern of punctuation (a period after the prefix URI and after the ?field) --%> 

<v:jsonset var="dataDescriptionAssertion" >      
    ?researchDataUri <${dataDescriptionPred}> ?dataDescription .
</v:jsonset>


<%--  Note there is really no difference in how things are set up for an object property except
      below in the n3ForEdit section, in whether the ..Existing variable goes in SparqlForExistingLiterals
      or in the SparqlForExistingUris, as well as perhaps in how the options are prepared --%>

<c:set var="theme" value="http://xmlns.com/foaf/0.1/theme"/>
<c:set var="themeUri" value="http://ANDSON.anu.edu.au/ns/0.1#individual1163021307"/>


	

<v:jsonset var="n3ForStmtToResearchData">       
    @prefix ands: <${vitroands}> .
   @prefix core: <${vivoCore}> .     
    
    ?publication  ands:hasResearchData  ?researchDataUri.
    ?researchDataUri ands:publishedIn ?publication .
    
    ?researchDataUri  a <${researchDataClass}> ;
                 a  <${flagURI}> .
</v:jsonset>



<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/entity",

    "subject"   : ["publication",    "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["researchDataUri", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForStmtToResearchData}", "${researchDataLabelAssertion}",  "${dataDescriptionAssertion}" ],


    
    "n3optional"    : [ ],
                        
    "newResources"  : { "researchDataUri" : "${defaultNamespace}" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : [ ],
    "literalsOnForm" :  [ "researchDataLabel","dataDescription" ],                          
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "researchDataLabel"              : "${researchDataLabelExisting}"
    },
    "sparqlForExistingUris" : { },
    "fields" : {
      "researchDataLabel" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${researchDataLabelAssertion}" ]
      },
      "dataDescription" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${dataDescriptionAssertion}" ]
      }
  }
}
</c:set>
<%
    log.debug(request.getAttribute("editjson"));

    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if (editConfig == null)
    {
        editConfig = new EditConfiguration((String) request.getAttribute("editjson"));     
        EditConfiguration.putConfigInSession(editConfig,session);
    }
    
    editConfig.addValidator(new StartYearBeforeEndYear("startYear","endYear") ); 
    		
    Model model = (Model) application.getAttribute("jenaOntModel");
    String objectUri = (String) request.getAttribute("objectUri");
    if (objectUri != null) { // editing existing
        editConfig.prepareForObjPropUpdate(model);
    } else { // adding new
        editConfig.prepareForNonUpdate(model);
    }
    
    String subjectName = ((Individual) request.getAttribute("subject")).getName();
%> 

    <c:set var="subjectName" value="<%= subjectName %>" />
<%
    if (objectUri != null) { // editing existing entry
%>
        <c:set var="editType" value="edit" />
        <c:set var="title" value="Edit position entry for ${subjectName}" />
        <%-- NB This will be the button text when Javascript is disabled. --%>
        <c:set var="submitLabel" value="Save changes" />
<% 
    } else { // adding new entry
%>
        <c:set var="editType" value="add" />
        <c:set var="title" value="Create a new Record Description entry for ${subjectName}" />
        <%-- NB This will be the button text when Javascript is disabled. --%>
        <c:set var="submitLabel" value="Create Record Description" />
<%  } 
    
    List<String> customJs = new ArrayList<String>(Arrays.asList("forms/js/customFormWithAutocomplete.js"
                                                                //, "forms/js/customFormTwoStep.js"
                                                                ));
    request.setAttribute("customJs", customJs);
    
    List<String> customCss = new ArrayList<String>(Arrays.asList("forms/css/customForm.css"
                                                                 ));
    request.setAttribute("customCss", customCss);   
%>

<c:set var="requiredHint" value="<span class='requiredHint'> *</span>" />

<jsp:include page="${preForm}">
	<jsp:param name="useTinyMCE" value="true"/>
</jsp:include>
<script language="JavaScript" type="text/javascript" src="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/js/MelbUni/toggleCheckBoxes.js"></script>
<h2>${title}</h2>

<form name="addForm" class="${editType}" action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    
   
    <div class="entry"> 
        <v:input type="text" label="Title ${requiredHint}" id="researchDataLabel" size="30" />
<v:input type="textarea" label="Description ${requiredHint}" id="dataDescription" rows="2" />
    </div>
    
    <!-- Processing information for Javascript -->
    <input type="hidden" name="editType" value="${editType}" />
    <input type="hidden" name="entryType" value="researchData" /> 
   
    <%-- RY If set steps to 1 when editType == 'edit', may be able to combine the
    step 1 and edit cases in the Javascript.  --%>
    <input type="hidden" name="steps" value="2" />
       
    <p class="submit"><v:input type="submit" id="submit" value="${submitLabel}" cancel="${param.subjectUri}"/></p>
    
    <p id="requiredLegend" class="requiredHint">* required fields</p>
    <div>
        <p style="float: left;">The following statements can be added to the record: </p>
        <p style="float:right"><a href="#" onClick="unCheckAll(document.addForm.list); return false;">Select None</a> - <a href="#" onClick="checkAll(document.addForm.list); return false;">Select All</a></p>
        <div style="clear: both;"></div>
    </div>
    <br>
    <ul>${inheritedCustodians}</ul>
</form>

<jsp:include page="${postForm}"/>

