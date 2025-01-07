#!/usr/bin/env zx

import { $, fs, cd, syncProcessCwd } from 'zx';

await exists('git');
await exists('gh');

const disabledRepos = [];
const allowedOwners = [];
const choreBranchName = 'chore/disable-codeql'

syncProcessCwd();
$.shell = '/bin/zsh'
const repoRoot = `${os.homedir()}/Documents/repos`;
cd(repoRoot);

const dirs = (await $`ls -d */`).stdout.split('\n')
    .filter(Boolean)
    .filter(repo => disabledRepos.indexOf(repo) === -1);

let prList = [];
for (let repo of dirs) {
    await within(async () => {
        cd(repo);

        const yamlFilePath = `${process.cwd()}/.github/workflows/codeql.yml`;
        const hasCodeQLConfig = await fs.exists(yamlFilePath);
    
        if (!hasCodeQLConfig) return;

        let defaultBranch;

        try {
            const result = await $`git remote show origin | grep 'HEAD branch' | awk '{print $NF}'`;
            defaultBranch = result.stdout.replaceAll('\n', '')
        } catch (err) {
            console.log(err)
            return;
        }
   
        const codeowners = await $`cat ${process.cwd()}/.github/CODEOWNERS`
    
        if (allowedOwners.some(owner => codeowners.stdout.includes(owner))) {
            console.log(`Processing repo: ${repo}, defaultBranch: ${defaultBranch}`);
            // TODO: doesnt cover scenario if owners change after fethcing remote changes...
            
            await $`git add .`;
            await $`git stash save "chore: switch to disable code_ql"`

            await $`git checkout ${defaultBranch}`;
            await $`git pull`

            try {
                await $`git checkout -b ${choreBranchName}`
            } catch (err) {
                if (err.exitCode === 128) {
                    await $`git checkout ${choreBranchName}`;
                } else {
                    console.log(err);
                    return;
                }
            }

            await $`git rm .github/workflows/codeql.yml`;
            await $`git rm -r .github/codeql/codeql-config.yml`

            await $`git commit --no-verify -m "chore: remove CodeQL"`            
            await $`git push --no-verify`;

            const prDetails = await $`gh pr create \
                --title "chore: remove CodeQL" \
                --body "This PR disables CodeQL" \
                --base ${defaultBranch} \
                --head ${choreBranchName}
            `;
            prList.push(prDetails.stdout.split('\n')[0]); 
        }   
    })
    
    cd(repoRoot)
}

async function exists(execName) {
    const err = new Error(`Exec '${execName}' should be installed`); 
    try {
        const result = await $`command -v ${execName} >/dev/null 2>&1`
        if (result.exitCode !== 0) throw err;
    } catch (e) {
        throw err;
    }
    return true;
}

console.log('Created PRs:');
console.log(prList.join('\n'))