
<%
/**
 * OpenCPS is the open source Core Public Services software
 * Copyright (C) 2016-present OpenCPS community
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
%>
<%@page import="org.opencps.servicemgt.service.ServiceInfoLocalServiceUtil"%>
<%@page import="org.opencps.servicemgt.model.ServiceInfo"%>
<%@page import="com.liferay.portlet.documentlibrary.util.DLUtil"%>
<%@page import="org.opencps.util.DLFileEntryUtil"%>
<%@page import="com.liferay.portal.kernel.repository.model.FileEntry"%>
<%@page import="org.opencps.dossiermgt.service.DossierFileLocalServiceUtil"%>
<%@page import="org.opencps.dossiermgt.model.DossierFile"%>
<%@page import="org.opencps.dossiermgt.util.DossierMgtUtil"%>
<%@page import="org.opencps.dossiermgt.service.DossierPartLocalServiceUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.opencps.dossiermgt.model.DossierPart"%>
<%@page import="org.opencps.dossiermgt.model.DossierTemplate"%>
<%@page import="org.opencps.util.WebKeys"%>
<%@page import="org.opencps.dossiermgt.model.Dossier"%>
<%@page import="org.opencps.dossiermgt.service.DossierLogLocalServiceUtil"%>
<%@page import="org.opencps.dossiermgt.model.DossierLog"%>
<%@page import="java.util.List"%>
<%@page import="org.opencps.util.DictItemUtil"%>
<%@page import="org.opencps.util.DateTimeUtil"%>
<%@page import="org.opencps.util.PortletConstants"%>
<%@page import="org.opencps.util.PortletUtil"%>
<%@ include file="../../init.jsp"%>

<%
	Dossier dossier = (Dossier) request.getAttribute(WebKeys.DOSSIER_ENTRY);
	DossierTemplate dossierTemplate = (DossierTemplate) request.getAttribute(WebKeys.DOSSIER_TEMPLATE_ENTRY);
%>

<c:choose>
	<c:when test="<%=dossier != null && dossier.getDossierStatus() != PortletConstants.DOSSIER_STATUS_NEW %>">
		<%
			String[] actors = new String[]{};
			String[] requestCommands = new String[]{StringPool.APOSTROPHE + WebKeys.DOSSIER_LOG_RESUBMIT_REQUEST + StringPool.APOSTROPHE, 
													StringPool.APOSTROPHE + WebKeys.DOSSIER_LOG_PAYMENT_REQUEST + StringPool.APOSTROPHE};
			List<DossierLog> dossierLogs = DossierLogLocalServiceUtil.findRequiredProcessDossier(dossier.getDossierId(), actors, requestCommands);
			List<DossierPart> dossierPartsLevel1 = new ArrayList<DossierPart>();
			
			int countDossierFileConfig = 0;
			
			ServiceInfo info = null;
			String serviceInfoName = StringPool.BLANK;
			
			try {
				
				info = ServiceInfoLocalServiceUtil.getServiceInfo(dossier.getServiceInfoId());
				serviceInfoName = info.getServiceName();
				
			} catch (Exception e) {}
				
			if(dossierTemplate != null){
				
				try{
					List<DossierPart> lstTmp1 = DossierPartLocalServiceUtil.getDossierPartsByT_P_PT(dossierTemplate.getDossierTemplateId(), 0, PortletConstants.DOSSIER_PART_TYPE_RESULT);
					if(lstTmp1 != null){
						dossierPartsLevel1.addAll(lstTmp1);
					}
				}catch(Exception e){}
				
				try{
					List<DossierPart> lstTmp2 = DossierPartLocalServiceUtil.getDossierPartsByT_P_PT(dossierTemplate.getDossierTemplateId(), 0, PortletConstants.DOSSIER_PART_TYPE_MULTIPLE_RESULT);
					if(lstTmp2 != null){
						dossierPartsLevel1.addAll(lstTmp2);
					}
				}catch(Exception e){}
				
				
			}
		%>
		
		<aui:row cssClass="pd_b20">
			<aui:col width="20" cssClass="bold">
				<liferay-ui:message key="dossier-service-name"/>
			</aui:col>
			<aui:col width="80">
				<%=serviceInfoName %>
			</aui:col>
		</aui:row>
		
		<aui:row>
			<aui:col width="50">
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-create-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getCreateDate()) ?
							DateTimeUtil.convertDateToString(dossier.getCreateDate(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME 
						%>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-receive-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getReceiveDatetime()) ?
							DateTimeUtil.convertDateToString(dossier.getReceiveDatetime(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME 
						%>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-estimate-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getEstimateDatetime()) ? 
							DateTimeUtil.convertDateToString(dossier.getEstimateDatetime(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME
						%>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-update-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getModifiedDate()) ? 
							DateTimeUtil.convertDateToString(dossier.getModifiedDate(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME
						%>
					</aui:col>
				</aui:row>
				
			</aui:col>
			
			<aui:col width="50">
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-submit-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getSubmitDatetime()) ? 
							DateTimeUtil.convertDateToString(dossier.getSubmitDatetime(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME
						%>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-reception-no"/>
					</aui:col>
					
					<aui:col width="70">
						<%=Validator.isNotNull(dossier.getReceptionNo()) ? dossier.getReceptionNo() : StringPool.DASH %>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="dossier-finish-date"/>
					</aui:col>
					<aui:col width="70">
						<%=
							Validator.isNotNull(dossier.getFinishDatetime()) ? 
							DateTimeUtil.convertDateToString(dossier.getFinishDatetime(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
							DateTimeUtil._EMPTY_DATE_TIME
						%>
					</aui:col>
				</aui:row>
				
				<aui:row>
					<aui:col width="30" cssClass="bold">
						<liferay-ui:message key="log-status"/>
					</aui:col>
					<aui:col width="70">
						<%=PortletUtil.getDossierStatusLabel(dossier.getDossierStatus(), locale) %>
					</aui:col>
				</aui:row>
			</aui:col>
				
		</aui:row>
		
		<c:if test="<%=dossierLogs != null && !dossierLogs.isEmpty() %>">
		
			<aui:row cssClass="bottom-line mg-l-30 pd_b20 pd_t20 pd-r60"></aui:row>
		
			<aui:row cssClass="pd_t20">
				<label class="bold uppercase">
					<liferay-ui:message key="required-process"/>
				</label>
			
					<%
					
						int count = 1;
						for(DossierLog dossierLog : dossierLogs){
							
							%>
								<aui:row cssClass='<%=count <  dossierLogs.size() ? "bottom-line pd_b20 pd_t20" : "pd_t20" %>'>
									<aui:col width="30">
										<span class="span1">
											<i class="fa fa-circle blue sx10"></i>
										</span>
										
										<span class="span2 bold">
											<%=count %>
										</span>
										
										<span class="span9">
											<%=
												Validator.isNotNull(dossierLog.getUpdateDatetime()) ? 
												DateTimeUtil.convertDateToString(dossierLog.getUpdateDatetime(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
												DateTimeUtil._EMPTY_DATE_TIME
											%>
										</span>
									</aui:col>
									<aui:col width="30">
										<span class="span4 bold">
											<liferay-ui:message key="request-command"/>
										</span>
										<span class="span8">
											<liferay-ui:message key="<%=dossierLog.getRequestCommand() %>"/>
										</span>
									</aui:col>
									<aui:col width="30">
										<span class="span4 bold">
											<liferay-ui:message key="message-info"/>
										</span>
										<span class="span8">
											<%= DossierMgtUtil.getDossierLogs(PortletConstants.REQUEST_COMMAND_PAYMENT, dossierLog.getMessageInfo()) %>
										</span>
									</aui:col>
								</aui:row>
								
							<%
							count ++;
						}
					%>
				
			</aui:row>
		</c:if>
		
		<c:if test="<%= dossierPartsLevel1 != null && !dossierPartsLevel1.isEmpty() %>">
		
			<aui:row cssClass="bottom-line mg-l-30 pd_b20 pd_t20 pd-r60"></aui:row>
			
			<aui:row cssClass="pd_t20">
				<label class="bold uppercase">
					<liferay-ui:message key="dossier-file-result"/>
				</label>
				<%
					List<DossierFile> dossierFilesConfig = new ArrayList<DossierFile>();
					int count1 = 1;
					int partTypeTemp = 0;
					for (DossierPart dossierPartLevel1 : dossierPartsLevel1){
						
					int partTypeConfig = dossierPartLevel1.getPartType();
					partTypeTemp = partTypeConfig;
					
					List<DossierPart> dossierParts = DossierMgtUtil.getTreeDossierPart(dossierPartLevel1.getDossierpartId());
					if(dossierParts != null){
						for(DossierPart dossierPart : dossierParts){
							DossierFile dossierFile = null;
							try{
								dossierFile = DossierFileLocalServiceUtil.getDossierFileInUse(dossier.getDossierId(), dossierPart.getDossierpartId());
							}catch(Exception e){
								continue;
							}
							//add rr
							dossierFilesConfig.add(dossierFile);
						}
					}
					}
					
					
					if(orderBydDossierFile.equals(WebKeys.ORDER_BY_ASC)) {
						dossierFilesConfig = DossierMgtUtil.orderDossierFileByDossierFileDate(WebKeys.ORDER_BY_ASC ,dossierFilesConfig);
					} else if (orderBydDossierFile.equals(WebKeys.ORDER_BY_DESC)) {
						dossierFilesConfig = DossierMgtUtil.orderDossierFileByDossierFileDate(WebKeys.ORDER_BY_DESC ,dossierFilesConfig);
					}
					 
				%>
				<c:if test="<%=partTypeTemp == PortletConstants.DOSSIER_PART_TYPE_RESULT  && Validator.isNotNull(orderFieldDossierFile)%>">
					<%
						for(DossierFile dossierFile : dossierFilesConfig) {
							
							String fileURL = StringPool.BLANK;
							
							try{
								FileEntry fileEntry = DLFileEntryUtil.getFileEntry(dossierFile.getFileEntryId());
								if(fileEntry != null){
									fileURL = DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), 
											themeDisplay, StringPool.BLANK);
								}
							}catch(Exception e){
								continue;
								
							}
					
					%>
							
							<aui:row cssClass='<%=count1 > 1 ? "top-line pd_b20 pd_t20" : "pd_b20 pd_t20" %>'>
								<aui:col width="50">
									<aui:row>
										<aui:col width="50">
											<span class="span1">
												<i class="fa fa-circle blue sx10"></i>
											</span>
											<span class="span2">
												<%=count1 %>
											</span>
											<span class="span9">
												<%=
													Validator.isNotNull(dossierFile.getDossierFileDate()) ? 
													DateTimeUtil.convertDateToString(dossierFile.getDossierFileDate(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
													DateTimeUtil._EMPTY_DATE_TIME
												%>
											</span>
										</aui:col>
										<aui:col width="50">
											<span class="span5 bold">
												<liferay-ui:message key="dossier-file-no"/>
											</span>
											<span class="span7">
												<%=Validator.isNotNull(dossierFile.getDossierFileNo()) ? dossierFile.getDossierFileNo() : StringPool.DASH %>
											</span>
										</aui:col>
									</aui:row>
								</aui:col>
								<aui:col width="50">
									<span class="span3 bold">
										<liferay-ui:message key="dossier-file-name"/>
									</span>
									<span class="span6">
										<a class="blue" href="<%=fileURL%>" target="_blank">
											<%=Validator.isNotNull(dossierFile.getDisplayName()) ? dossierFile.getDisplayName() : StringPool.BLANK  %>
										</a>
									</span>
									<span class="span3">
										
									</span>
								</aui:col>
							</aui:row>
							
							<%
							count1 ++;
						}
					%>
				</c:if>
		
				<%
					int count = 1;
					for (DossierPart dossierPartLevel1 : dossierPartsLevel1){
						
					int partType = dossierPartLevel1.getPartType();
					 
				%>
					
				<c:choose>
					<c:when test="<%=partType == PortletConstants.DOSSIER_PART_TYPE_RESULT && Validator.isNull(orderFieldDossierFile)%>">
						<%
									List<DossierPart> dossierParts = DossierMgtUtil.getTreeDossierPart(dossierPartLevel1.getDossierpartId());
									if(dossierParts != null){
										for(DossierPart dossierPart : dossierParts){
											DossierFile dossierFile = null;
											try{
												dossierFile = DossierFileLocalServiceUtil.getDossierFileInUse(dossier.getDossierId(), dossierPart.getDossierpartId());
											}catch(Exception e){
												continue;
											}
											
											if(dossierFile.getFileEntryId() <= 0 || dossierFile.getSyncStatus() != PortletConstants.DOSSIER_FILE_SYNC_STATUS_SYNCSUCCESS){
												continue;
											}
											
											
											String fileURL = StringPool.BLANK;
											
											try{
												FileEntry fileEntry = DLFileEntryUtil.getFileEntry(dossierFile.getFileEntryId());
												if(fileEntry != null){
													fileURL = DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), 
															themeDisplay, StringPool.BLANK);
												}
											}catch(Exception e){
												continue;
												
											}
									
									%>
									
										<aui:row cssClass='<%=count > 1 ? "top-line pd_b20 pd_t20" : "pd_b20 pd_t20" %>'>
												<aui:col width="50">
													<aui:row>
														<aui:col width="50">
															<span class="span1">
																<i class="fa fa-circle blue sx10"></i>
															</span>
															<span class="span2">
																<%=count %>
															</span>
															<span class="span9">
																<%=
																	Validator.isNotNull(dossierFile.getDossierFileDate()) ? 
																	DateTimeUtil.convertDateToString(dossierFile.getDossierFileDate(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
																	DateTimeUtil._EMPTY_DATE_TIME
																%>
															</span>
														</aui:col>
														<aui:col width="50">
															<span class="span5 bold">
																<liferay-ui:message key="dossier-file-no"/>
															</span>
															<span class="span7">
																<%=Validator.isNotNull(dossierFile.getDossierFileNo()) ? dossierFile.getDossierFileNo() : StringPool.DASH %>
															</span>
														</aui:col>
													</aui:row>
												</aui:col>
												<aui:col width="50">
													<span class="span3 bold">
														<liferay-ui:message key="dossier-file-name"/>
													</span>
													<span class="span6">
														<a class="blue" href="<%=fileURL%>" target="_blank">
															<%=Validator.isNotNull(dossierFile.getDisplayName()) ? dossierFile.getDisplayName() : StringPool.BLANK  %>
														</a>
													</span>
													<span class="span3">
														
													</span>
												</aui:col>
											</aui:row>
											
										<%
										
										count++;
									}
								}
							
						%>
							
					</c:when>

					<c:when test="<%= partType == PortletConstants.DOSSIER_PART_TYPE_MULTIPLE_RESULT%>">
						<%
							List<DossierFile> dossierFiles = new ArrayList<DossierFile>();
							if(Validator.isNull(orderFieldDossierFile)) {
								DossierFileLocalServiceUtil.
								getDossierFileByD_DP(dossier.getDossierId(), dossierPartLevel1.getDossierpartId());
							} else {
								countDossierFileConfig = DossierFileLocalServiceUtil.countDossierFileByD_DP_Config(dossier.getDossierId(), dossierPartLevel1.getDossierpartId());
								DossierFileLocalServiceUtil.
								getDossierFileByD_DP_Config(dossier.getDossierId(), dossierPartLevel1.getDossierpartId(),
										DossierMgtUtil.getDossierFileOrderByComparator(orderFieldDossierFile, orderBydDossierFile),
										WebKeys.SEARCH_START, countDossierFileConfig);
							}
							
							int index = 0;
							if (Validator.isNotNull(dossierFiles)) 
							{
								for(DossierFile df : dossierFiles) {
								index++;
								String fileURL = StringPool.BLANK;
								
								try{
									FileEntry fileEntry = DLFileEntryUtil.getFileEntry(df.getFileEntryId());
									if(fileEntry != null){
										fileURL = DLUtil.getPreviewURL(fileEntry, fileEntry.getFileVersion(), 
												themeDisplay, StringPool.BLANK);
									}
								}catch(Exception e){
									continue;
									
								}

						%>
									<aui:row cssClass='<%=index > 1 ? "top-line pd_b20 pd_t20" : "pd_b20 pd_t20" %>'>
										<aui:col width="50">
											<aui:row>
												<aui:col width="50">
													<span class="span1">
														<i class="fa fa-circle blue sx10"></i>
													</span>
													<span class="span2">
														<%=index %>
													</span>
													<span class="span9">
														<%=
															Validator.isNotNull(df.getDossierFileDate()) ? 
															DateTimeUtil.convertDateToString(df.getDossierFileDate(), DateTimeUtil._VN_DATE_TIME_FORMAT) : 
															DateTimeUtil._EMPTY_DATE_TIME
														%>
													</span>
												</aui:col>
												<aui:col width="50">
													<span class="span5 bold">
														<liferay-ui:message key="dossier-file-no"/>
													</span>
													<span class="span7">
														<%=Validator.isNotNull(df.getDossierFileNo()) ? df.getDossierFileNo() : StringPool.DASH %>
													</span>
												</aui:col>
											</aui:row>
										</aui:col>
										<aui:col width="50">
											<span class="span3 bold">
												<liferay-ui:message key="dossier-file-name"/>
											</span>
											<span class="span6">
												<a class="blue" href="<%=fileURL%>" target="_blank">
													<%=Validator.isNotNull(df.getDisplayName()) ? df.getDisplayName() : StringPool.BLANK  %>
												</a>
											</span>
											<span class="span3">
												
											</span>
										</aui:col>
									</aui:row>
								
						<%
								}
							}
						%>
					</c:when>
				</c:choose>
				<%
					}
				%>
			</aui:row>
				
		</c:if>
		
	</c:when>
	
	<c:otherwise>
		<div class="portlet-msg-info">
			<liferay-ui:message key="no-dossier-result-info"/>
		</div>
	</c:otherwise>
	
</c:choose>