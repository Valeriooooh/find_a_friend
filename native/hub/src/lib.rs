//! This `hub` crate is the
//! entry point of the Rust logic.

mod common;
mod messages;

use std::str::FromStr;
use common::Result;
use futures::StreamExt;
use iroh::{
    base::node_addr::AddrInfoOptions,
    blobs::store::fs::Store,
    client::docs::{self, ShareMode},
    docs::{store::Query, AuthorId},
    net::relay::RelayMode,
    node::{Node, RpcStatus},
};
use iroh::base::ticket::Error;
use iroh::client::docs::Entry;
use iroh::docs::{Author, NamespaceId};
use messages::basic::{
    document_list_response::DocPair, DocumentCreateRequest, DocumentCreateResponse,
    DocumentListRequest, DocumentListResponse,
};
// use messages;
use tokio;
use crate::messages::basic::{DocumentTicketRequest, DocumentTicketResponse};
// Comment this line to target the web.
           // use tokio_with_wasm::alias as tokio; // Uncomment this line to target the web.

rinf::write_interface!();

const IROH_DIR: &str = "/data/data/com.example.find_a_friend/files/";
const SHARE_TICKET: &str = "share_ticket";

struct App;

impl App {
    async fn new() -> Result<(Node<Store>, AuthorId)> {
        let node = Node::persistent(IROH_DIR).await?;
        let node = node.relay_mode(RelayMode::Default);
        let node = node
            .enable_rpc_with_addr(iroh::node::DEFAULT_RPC_ADDR)
            .await?;
        let node = node.spawn().await?;
        let _author = node.authors().default().await?;
        Ok((node, _author))
    }
}

// Use `tokio::spawn` to run concurrent tasks.
// Always use non-blocking async functions
// such as `tokio::fs::File::open`.
// If you really need to use blocking code,
// use `tokio::task::spawn_blocking`.
async fn main() {
    let _ = RpcStatus::clear(IROH_DIR).await;
    let Ok((mut node, author)) = App::new().await else {
        {
            rinf::debug_print!("startup failed!");
            panic!("startup failed!");
        }
    };
    rinf::debug_print!(
        "startup succeded \n\n NodeId: {} \n\n AuthorId {}",
        node.node_id(),
        author.to_string()
    );
    tokio::spawn(doc_list_get(node.clone()));
    tokio::spawn(doc_create(node.clone(), author.clone()));
    tokio::spawn(get_ticket(node.clone(), author.clone()));
}

async fn doc_list_get(node: Node<Store>) -> Result<()> {
    let mut sig = DocumentListRequest::get_dart_signal_receiver()?;
    while let Some(_dart_signal) = sig.recv().await {
        let mut docs = vec![];
        if let Ok(mut a) = node.docs().list().await {
            while let Some(item) = a.next().await {
                let item = item?;
                if let Ok(Some(thisdoc)) = node.client().docs().open(item.clone().0).await {
                    if let Ok(party_name) = thisdoc.get_one(Query::key_exact("party_name")).await {
                        docs.push((item, party_name));
                    } else {
                        docs.push((item, None))
                    }
                }
            }
        };
        //rinf::debug_print!("{docs:?}");
        let mut docs2 = vec![];
        for (x, y) in docs {
            if let Some(a) = y.to_owned() {
                let content = a.content_bytes(node.client()).await.unwrap().to_vec();
                docs2.push(DocPair {
                    document: x.0.to_string(),
                    doc_name: Some(String::from_utf8(content).unwrap()),
                });
            } else {
                docs2.push(DocPair {
                    document: x.0.to_string(),
                    doc_name: None,
                });
            };
        }
        DocumentListResponse { document: docs2 }.send_signal_to_dart();
    }
    Ok(())
}

async fn doc_create(node: Node<Store>, author: AuthorId) -> Result<()> {
    let mut sig = DocumentCreateRequest::get_dart_signal_receiver()?;
    while let Some(_dart_signal) = sig.recv().await {
        let Ok(mut new_doc) = node.docs().create().await else {
            DocumentCreateResponse { ticket: None }.send_signal_to_dart();
            return Ok(());
        };
        let Ok(ticket) = new_doc.share(ShareMode::Write, AddrInfoOptions::Id).await else {
            DocumentCreateResponse { ticket: None }.send_signal_to_dart();
            return Ok(());
        };
        let _ = new_doc
            .set_bytes(author, SHARE_TICKET, ticket.to_string())
            .await;
        let _ = new_doc.set_bytes(author, "party_name", "Party Name").await;
        DocumentCreateResponse {
            ticket: Some(ticket.to_string()),
        }
        .send_signal_to_dart();
        rinf::debug_print!("{ticket:?}");
    }
    Ok(())
}

async fn get_ticket(node: Node<Store>, author: AuthorId) -> Result<()>{
    let mut sig = DocumentTicketRequest::get_dart_signal_receiver()?;
    while let Some(_dart_signal) = sig.recv().await {
        let a = _dart_signal.message.document_id.as_str();
        if let Ok(Some(doc)) = node.client().docs().open(NamespaceId::from_str(a)?).await{
            if let Ok(query) = doc.get_one(Query::key_exact(SHARE_TICKET)).await{
                match query{
                    None => {
                        if let Ok(ticket) = doc.share(ShareMode::Write, AddrInfoOptions::Id).await{
                            let _ = doc.set_bytes(author, SHARE_TICKET, ticket.to_string());
                            DocumentTicketResponse{ticket: ticket.to_string()}.send_signal_to_dart();
                        };
                    }
                    Some(a) => {
                        if let Ok(q) = a.content_bytes(node.client()).await{
                            let ticket = String::from_utf8(q.to_vec()).unwrap();
                            DocumentTicketResponse{ticket}.send_signal_to_dart();
                        };

                    }
                }
            };
        };
    }
    Ok(())
}