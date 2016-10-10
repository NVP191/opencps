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
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

package org.opencps.backend.exc;

import java.util.ArrayList;
import java.util.List;

import javax.jms.JMSException;
import javax.naming.NamingException;

import org.opencps.backend.message.SendToBackOfficeMsg;
import org.opencps.backend.message.SendToCallbackMsg;
import org.opencps.backend.util.BackendUtils;
import org.opencps.dossiermgt.model.Dossier;
import org.opencps.dossiermgt.model.DossierFile;
import org.opencps.dossiermgt.model.DossierPart;
import org.opencps.dossiermgt.service.DossierFileLocalServiceUtil;
import org.opencps.dossiermgt.service.DossierLocalServiceUtil;
import org.opencps.dossiermgt.service.DossierPartLocalServiceUtil;
import org.opencps.jms.context.JMSHornetqContext;
import org.opencps.jms.message.SyncFromBackOfficeMessage;
import org.opencps.jms.message.body.DossierFileMsgBody;
import org.opencps.jms.message.body.SyncFromBackOfficeMsgBody;
import org.opencps.jms.util.JMSMessageBodyUtil;
import org.opencps.jms.util.JMSMessageUtil;
import org.opencps.processmgt.model.WorkflowOutput;
import org.opencps.processmgt.service.WorkflowOutputLocalServiceUtil;
import org.opencps.util.PortletConstants;
import org.opencps.util.WebKeys;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.messaging.Message;
import com.liferay.portal.kernel.messaging.MessageBusUtil;
import com.liferay.portal.kernel.messaging.MessageListener;
import com.liferay.portal.kernel.messaging.MessageListenerException;

/**
 * @author khoavd
 */
public class MsgOutBackOffice implements MessageListener {

	@Override
	public void receive(Message message)
		throws MessageListenerException {

		_log.info("///////////////STARTING MsgOutBackOffice");

		SendToBackOfficeMsg toBackOffice =
			(SendToBackOfficeMsg) message.get("toBackOffice");

		boolean trustServiceMode =
			BackendUtils.checkServiceMode(toBackOffice.getDossierId());

		if (toBackOffice != null && toBackOffice.getCompanyId() > 0 &&
			!trustServiceMode) {

			JMSHornetqContext context = null;

			boolean statusUpdate = false;

			try {

				Dossier dossier =
					DossierLocalServiceUtil.fetchDossier(toBackOffice.getDossierId());

				List<DossierFile> dossierFiles = new ArrayList<DossierFile>();

				statusUpdate =
					DossierLocalServiceUtil.updateDossierStatus(
						toBackOffice.getDossierId(),
						toBackOffice.getFileGroupId(),
						toBackOffice.getDossierStatus(),
						toBackOffice.getReceptionNo(),
						toBackOffice.getEstimateDatetime(),
						toBackOffice.getSubmitDateTime(),
						toBackOffice.getReceiveDatetime(),
						toBackOffice.getFinishDatetime(),
						toBackOffice.getActor(), toBackOffice.getActorId(),
						toBackOffice.getActorName(),
						toBackOffice.getRequestCommand(),
						toBackOffice.getActionInfo(),
						toBackOffice.getMessageInfo());

				List<WorkflowOutput> workflowOutputs =
					WorkflowOutputLocalServiceUtil.getByProcessWFPostback(
						toBackOffice.getProcessWorkflowId(), true);

				// Check file return
				for (WorkflowOutput workflowOutput : workflowOutputs) {

					List<DossierFile> dossierFilesTemp = null;
					try {
						DossierPart dossierPart =

							DossierPartLocalServiceUtil.getDossierPart(workflowOutput.getDossierPartId());
						dossierFilesTemp =
							DossierFileLocalServiceUtil.getDossierFileByDID_SS_DPID_R(
								toBackOffice.getDossierId(),
								PortletConstants.DOSSIER_FILE_SYNC_STATUS_REQUIREDSYNC,
								dossierPart.getDossierpartId(), 0);

						dossierFiles.addAll(dossierFilesTemp);
					}
					catch (Exception e) {
						_log.error(e);
					}
				}

				DossierFileLocalServiceUtil.updateDossierFileResultSyncStatus(
					0, toBackOffice.getDossierId(),
					PortletConstants.DOSSIER_FILE_SYNC_STATUS_SYNCSUCCESS,
					workflowOutputs);

				List<DossierFileMsgBody> lstDossierFileMsgBody =
					JMSMessageBodyUtil.getDossierFileMsgBody(dossierFiles);

				// JMSContext context =
				// JMSMessageUtil.createProducer(
				// toBackOffice.getCompanyId(),
				// toBackOffice.getGovAgencyCode(), true,
				// WebKeys.JMS_QUEUE_OPENCPS_FRONTOFFICE.toLowerCase(),
				// WebKeys.JMS_QUEUE_OPENCPS_FRONTOFFICE.toLowerCase(),
				// "remote", "jmscore");

				context =
					JMSMessageUtil.createHornetqProducer(
						toBackOffice.getCompanyId(),
						toBackOffice.getGovAgencyCode(), true,
						WebKeys.JMS_QUEUE_OPENCPS.toLowerCase(),
						WebKeys.JMS_QUEUE_OPENCPS.toLowerCase(), "remote",
						"hornetq");

				_log.info("/////////////////////////Dossifile SIZE " +
					lstDossierFileMsgBody.size());

				SyncFromBackOfficeMessage syncFromBackoffice =
					new SyncFromBackOfficeMessage(context);

				SyncFromBackOfficeMsgBody msgBody =
					new SyncFromBackOfficeMsgBody();

				_log.info("################################## dossier.getReceptionNo()" +
					dossier.getReceptionNo() +
					"--Time--" +
					System.currentTimeMillis());

				_log.info("################################## toBackOffice.getReceptionNo()" +
					toBackOffice.getReceptionNo() +
					"--Time--" +
					System.currentTimeMillis());

				msgBody.setOid(dossier.getOid());
				msgBody.setReceptionNo(toBackOffice.getReceptionNo());
				msgBody.setFinishDatetime(toBackOffice.getFinishDatetime());
				msgBody.setDossierStatus(toBackOffice.getDossierStatus());
				msgBody.setLstDossierFileMsgBody(lstDossierFileMsgBody);
				msgBody.setReceiveDatetime(toBackOffice.getReceiveDatetime());
				msgBody.setSubmitDateTime(toBackOffice.getSubmitDateTime());
				msgBody.setEstimateDatetime(toBackOffice.getEstimateDatetime());
				msgBody.setPaymentFile(toBackOffice.getPaymentFile());
				msgBody.setActorId(toBackOffice.getActorId());
				msgBody.setActor(toBackOffice.getActor());
				msgBody.setActorName(toBackOffice.getActorName());
				msgBody.setActionInfo(toBackOffice.getActionInfo());
				msgBody.setMessageInfo(toBackOffice.getMessageInfo());
				msgBody.setFileGroupId(toBackOffice.getFileGroupId());
				msgBody.setRequestCommand(toBackOffice.getRequestCommand());
				syncFromBackoffice.sendMessageByHornetq(msgBody);

				// Send to Callback
				SendToCallbackMsg toCallBack = new SendToCallbackMsg();

				toCallBack.setProcessOrderId(toBackOffice.getProcessOrderId());
				toCallBack.setSyncStatus(statusUpdate ? "ok" : "error");
				toCallBack.setDossierStatus(toBackOffice.getDossierStatus());
				Message sendToCallBack = new Message();

				sendToCallBack.put("toCallback", toCallBack);

				MessageBusUtil.sendMessage(
					"opencps/backoffice/engine/callback", sendToCallBack);

			}
			catch (Exception e) {
				_log.error(e);
			}
			finally {
				if (context != null) {
					try {
						context.destroy();
					}
					catch (JMSException e) {
						_log.error(e);
					}
					catch (NamingException e) {
						_log.error(e);
					}
				}
			}
		}

	}

	private Log _log = LogFactoryUtil.getLog(MsgOutBackOffice.class);

}
